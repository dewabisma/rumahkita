import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/tables/sync_tables.dart';
import 'package:rumah/domain/enums/privilege_status.dart';
import 'package:rumah/domain/enums/privilege_usage_mode.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalUserSettings,
    HouseSync,
    HousematesSync,
    ScoreEvents,
    RemovalProposalsSync,
    ProposalVotesSync,
    CyclesSync,
    TasksSync,
    PrivilegesSync,
    PrivilegeRedemptionEvents,
    TaskClaimEvents,
    AuditLogAppendOnly,
    SyncOutboxEntries,
    SyncAppliedOps,
    SyncPeerState,
    SyncPeerAllowlist,
    ConsumedJoinCredentials,
    HouseJoinSecrets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(houseSync, houseSync.displayNameHlc);
            await m.addColumn(houseSync, houseSync.displayNameDeviceId);
            await m.addColumn(houseSync, houseSync.rulesVersionHlc);
            await m.addColumn(houseSync, houseSync.rulesVersionDeviceId);
            await m.addColumn(housematesSync, housematesSync.nicknameHlc);
            await m.addColumn(housematesSync, housematesSync.nicknameDeviceId);
            await m.addColumn(
              removalProposalsSync,
              removalProposalsSync.statusHlc,
            );
            await m.addColumn(
              removalProposalsSync,
              removalProposalsSync.statusDeviceId,
            );
            await m.addColumn(
              proposalVotesSync,
              proposalVotesSync.originDeviceId,
            );
            await m.addColumn(cyclesSync, cyclesSync.statusHlc);
            await m.addColumn(cyclesSync, cyclesSync.statusDeviceId);
            await m.addColumn(cyclesSync, cyclesSync.guardianHlc);
            await m.addColumn(cyclesSync, cyclesSync.guardianDeviceId);
            await m.addColumn(
              cyclesSync,
              cyclesSync.rulesVersionAtSignoffHlc,
            );
            await m.addColumn(
              cyclesSync,
              cyclesSync.rulesVersionAtSignoffDeviceId,
            );
            await m.addColumn(tasksSync, tasksSync.titleHlc);
            await m.addColumn(tasksSync, tasksSync.titleDeviceId);
            await m.addColumn(tasksSync, tasksSync.pointsHlc);
            await m.addColumn(tasksSync, tasksSync.pointsDeviceId);
            await m.addColumn(tasksSync, tasksSync.statusHlc);
            await m.addColumn(tasksSync, tasksSync.statusDeviceId);
          }
          if (from < 3) {
            await m.addColumn(houseSync, houseSync.privilegeTemplates);
            await m.addColumn(houseSync, houseSync.privilegeTemplatesHlc);
            await m.addColumn(houseSync, houseSync.privilegeTemplatesDeviceId);
          }
          if (from < 4) {
            await m.addColumn(houseSync, houseSync.cycleDurationDays);
            await m.addColumn(houseSync, houseSync.cycleDurationDaysHlc);
            await m.addColumn(houseSync, houseSync.cycleDurationDaysDeviceId);
            await m.addColumn(cyclesSync, cyclesSync.startedAtHlc);
            await m.addColumn(cyclesSync, cyclesSync.endsAtHlc);
            await m.addColumn(cyclesSync, cyclesSync.cycleStartScoresJson);
            await m.addColumn(cyclesSync, cyclesSync.handoverStep);
            await m.addColumn(cyclesSync, cyclesSync.handoverStepHlc);
            await m.addColumn(cyclesSync, cyclesSync.handoverStepDeviceId);
          }
          if (from < 5) {
            await m.addColumn(
              removalProposalsSync,
              removalProposalsSync.votingWindowEndsAtHlc,
            );
          }
          if (from < 6) {
            await m.createTable(privilegesSync);
            await m.createTable(privilegeRedemptionEvents);
            await _migratePrivilegeTemplatesToCatalog(m);
          }
          if (from < 7) {
            await m.addColumn(tasksSync, tasksSync.description);
            await m.addColumn(tasksSync, tasksSync.descriptionHlc);
            await m.addColumn(tasksSync, tasksSync.descriptionDeviceId);
            await m.addColumn(tasksSync, tasksSync.assignedToMemberId);
            await m.addColumn(tasksSync, tasksSync.assignedToMemberIdHlc);
            await m.addColumn(tasksSync, tasksSync.assignedToMemberIdDeviceId);
          }
        },
      );

  static Future<void> _migratePrivilegeTemplatesToCatalog(Migrator m) async {
    final houses = await m.database
        .customSelect('SELECT house_id, privilege_templates FROM house_sync')
        .get();
    final hlcService = HlcService(deviceId: 'migration');
    final hlcBytes = hlcService.toBytes(hlcService.now());
    final uuid = const Uuid();

    for (final houseRow in houses) {
      final houseId = houseRow.read<String>('house_id');
      final raw = houseRow.read<String>('privilege_templates');
      if (raw.isEmpty || raw == '{}') {
        continue;
      }
      final drafting = await m.database
          .customSelect(
            'SELECT cycle_id FROM cycles_sync WHERE house_id = ? AND status = ? LIMIT 1',
            variables: [
              Variable<String>(houseId),
              const Variable<String>('drafting'),
            ],
          )
          .getSingleOrNull();
      final active = drafting ??
          await m.database
              .customSelect(
                'SELECT cycle_id FROM cycles_sync WHERE house_id = ? AND status = ? LIMIT 1',
                variables: [
                  Variable<String>(houseId),
                  const Variable<String>('active'),
                ],
              )
              .getSingleOrNull();
      if (active == null) {
        continue;
      }
      final cycleId = active.read<String>('cycle_id');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        final isPenalty = map['is_penalty'] as bool? ?? false;
        final enabled = map['enabled'] as bool? ?? true;
        if (isPenalty || !enabled) {
          continue;
        }
        final threshold = map['unlock_threshold'] as int? ?? 50;
        final pointCost = threshold >= 90 ? 10 : (100 - threshold).clamp(10, 100);
        final privilegeId = uuid.v5(Uuid.NAMESPACE_URL, '$houseId|$cycleId|${entry.key}');
        await m.database.customInsert(
          'INSERT OR IGNORE INTO privileges_sync '
          '(privilege_id, house_id, cycle_id, name, description, point_cost, status, usage_mode, updated_at_hlc) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable<String>(privilegeId),
            Variable<String>(houseId),
            Variable<String>(cycleId),
            Variable<String>(map['name'] as String? ?? entry.key),
            Variable<String>(map['description'] as String? ?? ''),
            Variable<int>(pointCost),
            Variable<String>(PrivilegeStatus.active.wireValue),
            Variable<String>(PrivilegeUsageMode.durable.wireValue),
            Variable<Uint8List>(hlcBytes),
          ],
        );
      }
    }
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
