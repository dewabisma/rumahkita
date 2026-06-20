import 'package:drift/drift.dart';
import 'package:rumah/data/local/tables/sync_tables.dart';

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
  int get schemaVersion => 4;

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
        },
      );

  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
