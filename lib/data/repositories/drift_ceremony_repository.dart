import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/entities/cycle.dart';
import 'package:rumah/domain/entities/privilege_template.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/domain/repositories/ceremony_repository.dart';
import 'package:rumah/sync/ceremony_guardian.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

class DriftCeremonyRepository implements CeremonyRepository {
  DriftCeremonyRepository({
    required AppDatabase db,
    required SyncWriteCoordinator sync,
    Uuid? uuid,
  })  : _db = db,
        _sync = sync,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncWriteCoordinator _sync;
  final Uuid _uuid;

  @override
  Future<Cycle> startCeremony(String houseId) async {
    final existing = await _findCycleByStatus(
      houseId,
      CycleStatus.drafting,
    );
    if (existing != null) {
      return _toCycle(existing);
    }

    final activeCycle = await _findCycleByStatus(houseId, CycleStatus.active);
    if (activeCycle != null) {
      return _toCycle(activeCycle);
    }

    final placeholderGuardian = await _placeholderGuardian(houseId);
    final cycleId = _uuid.v4();
    final op = _sync.opFactory.cycleCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      cycleId: cycleId,
      activeGuardianMemberId: placeholderGuardian,
    );

    await _emit(houseId: houseId, senderMemberId: null, ops: [op]);

    final row = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingle();
    return _toCycle(row);
  }

  @override
  Future<Task> addTask({
    required String houseId,
    required String cycleId,
    required String title,
    required int points,
    required String actorMemberId,
  }) async {
    final taskId = _uuid.v4();
    final createOp = _sync.opFactory.taskCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      title: title,
      negotiatedPoints: points,
    );
    await _emitWithRulesBump(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [createOp],
    );

    final row = await (_db.select(_db.tasksSync)
          ..where((t) => t.taskId.equals(taskId)))
        .getSingle();
    return _toTask(row);
  }

  @override
  Future<void> updateTaskTitle({
    required String houseId,
    required String taskId,
    required String title,
    required String actorMemberId,
  }) async {
    final updateOp = _sync.opFactory.taskFieldUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      field: 'title',
      value: title,
    );
    await _emitWithRulesBump(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [updateOp],
    );
  }

  @override
  Future<void> updateTaskPoints({
    required String houseId,
    required String taskId,
    required int points,
    required String actorMemberId,
  }) async {
    final updateOp = _sync.opFactory.taskFieldUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      field: 'negotiated_points',
      value: points,
    );
    await _emitWithRulesBump(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [updateOp],
    );
  }

  @override
  Future<void> archiveTask({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  }) async {
    final updateOp = _sync.opFactory.taskFieldUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      field: 'status',
      value: TaskStatus.archived.wireValue,
    );
    await _emitWithRulesBump(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [updateOp],
    );
  }

  @override
  Future<void> updatePrivilegeTemplates({
    required String houseId,
    required Map<String, PrivilegeTemplate> templates,
    required String actorMemberId,
  }) async {
    final jsonMap = {
      for (final entry in templates.entries) entry.key: entry.value.toJson(),
    };
    final templatesOp = _sync.opFactory.housePrivilegeTemplatesUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      templatesJson: jsonMap,
    );
    await _emitWithRulesBump(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [templatesOp],
    );
  }

  @override
  Future<void> acceptRules({
    required String houseId,
    required String cycleId,
    required String memberId,
  }) async {
    final signoffOp = _sync.opFactory.cycleSignoffSet(
      opId: _uuid.v4(),
      houseId: houseId,
      cycleId: cycleId,
      memberId: memberId,
      accepted: true,
    );
    await _emit(
      houseId: houseId,
      senderMemberId: memberId,
      ops: [signoffOp],
    );
  }

  Future<void> _emitWithRulesBump({
    required String houseId,
    required String? senderMemberId,
    required List<SyncOperation> ops,
  }) async {
    final currentVersion = await _currentRulesVersion(houseId);
    final bumpOp = _sync.opFactory.houseRulesVersionUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      rulesVersion: currentVersion + 1,
    );
    await _emit(
      houseId: houseId,
      senderMemberId: senderMemberId,
      ops: [...ops, bumpOp],
    );
  }

  Future<void> _emit({
    required String houseId,
    required String? senderMemberId,
    required List<SyncOperation> ops,
  }) async {
    final settings =
        await (_db.select(_db.localUserSettings)).getSingleOrNull();
    await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: senderMemberId,
      ops: ops,
    );
  }

  Future<int> _currentRulesVersion(String houseId) async {
    final row = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingle();
    return row.rulesVersion;
  }

  Future<String> _placeholderGuardian(String houseId) async {
    final housemates = await (_db.select(_db.housematesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final activeIds = housemates
        .where((m) => m.memberStatus == MemberStatus.active.wireValue)
        .map((m) => m.memberId)
        .toList()
      ..sort();
    if (activeIds.isEmpty) {
      throw StateError('Cannot start ceremony without active housemates');
    }
    return activeIds.first;
  }

  Future<CyclesSyncData?> _findCycleByStatus(
    String houseId,
    CycleStatus status,
  ) async {
    final rows = await (_db.select(_db.cyclesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.status.equals(status.wireValue),
          ))
        .get();
    if (rows.isEmpty) {
      return null;
    }
    rows.sort((a, b) => a.cycleId.compareTo(b.cycleId));
    return rows.first;
  }

  static Cycle _toCycle(CyclesSyncData row) {
    final rawSignoffs =
        Map<String, dynamic>.from(jsonDecode(row.ceremonySignoffs) as Map);
    final signoffs = <String, CeremonySignoff>{};
    for (final entry in rawSignoffs.entries) {
      if (entry.value is Map) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        signoffs[entry.key] = CeremonySignoff(
          accepted: map['accepted'] as bool? ?? false,
          hlc: map['hlc'] as String? ?? '',
          deviceId: map['device_id'] as String?,
        );
      }
    }
    return Cycle(
      cycleId: row.cycleId,
      houseId: row.houseId,
      activeGuardianMemberId: row.activeGuardianMemberId,
      status: CycleStatus.fromWire(row.status),
      ceremonySignoffs: signoffs,
      rulesVersionAtSignoff: row.rulesVersionAtSignoff,
      updatedAtHlc: row.updatedAtHlc,
    );
  }

  static Task _toTask(TasksSyncData row) {
    final claimed = jsonDecode(row.claimedByMemberIds) as List<dynamic>;
    return Task(
      taskId: row.taskId,
      houseId: row.houseId,
      cycleId: row.cycleId,
      title: row.title,
      negotiatedPoints: row.negotiatedPoints,
      status: TaskStatus.fromWire(row.status),
      claimedByMemberIds: claimed.cast<String>(),
      updatedAtHlc: row.updatedAtHlc,
    );
  }

  static Cycle cycleFromRow(CyclesSyncData row) => _toCycle(row);

  static Task taskFromRow(TasksSyncData row) => _toTask(row);
}

/// Activates a drafting cycle when all active members have accepted current rules.
Future<void> maybeActivateCycle({
  required AppDatabase db,
  required SyncWriteCoordinator sync,
  required String houseId,
  required String cycleId,
  Uuid? uuid,
}) async {
  final idGen = uuid ?? const Uuid();
  final cycleRow = await (db.select(db.cyclesSync)
        ..where((t) => t.cycleId.equals(cycleId)))
      .getSingleOrNull();
  if (cycleRow == null) {
    return;
  }

  final houseRow = await (db.select(db.houseSync)
        ..where((t) => t.houseId.equals(houseId)))
      .getSingleOrNull();
  if (houseRow == null) {
    return;
  }

  final housemates = await (db.select(db.housematesSync)
        ..where((t) => t.houseId.equals(houseId)))
      .get();
  final activeIds = housemates
      .where((m) => m.memberStatus == MemberStatus.active.wireValue)
      .map((m) => m.memberId)
      .toList();

  final signoffs =
      Map<String, dynamic>.from(jsonDecode(cycleRow.ceremonySignoffs) as Map);

  if (!isActivationGateMet(
    cycleStatus: CycleStatus.fromWire(cycleRow.status),
    rulesVersionAtSignoff: cycleRow.rulesVersionAtSignoff,
    houseRulesVersion: houseRow.rulesVersion,
    ceremonySignoffs: signoffs,
    activeMemberIds: activeIds,
  )) {
    return;
  }

  final guardianId = pickDeterministicGuardian(cycleId, activeIds);
  final guardianOp = sync.opFactory.cycleGuardianUpdate(
    opId: idGen.v4(),
    houseId: houseId,
    cycleId: cycleId,
    activeGuardianMemberId: guardianId,
  );
  final statusOp = sync.opFactory.cycleStatusTransition(
    opId: idGen.v4(),
    houseId: houseId,
    cycleId: cycleId,
    from: CycleStatus.drafting.wireValue,
    to: CycleStatus.active.wireValue,
  );

  final settings =
      await (db.select(db.localUserSettings)).getSingleOrNull();
  await sync.emitLocalOps(
    houseId: houseId,
    tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
    senderMemberId: null,
    ops: [guardianOp, statusOp],
  );
}

/// Bumps rules version when a new member joins during drafting.
Future<void> bumpRulesVersionIfDrafting({
  required AppDatabase db,
  required SyncWriteCoordinator sync,
  required String houseId,
  required String? senderMemberId,
  Uuid? uuid,
}) async {
  final idGen = uuid ?? const Uuid();
  final drafting = await (db.select(db.cyclesSync)
        ..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.status.equals(CycleStatus.drafting.wireValue),
        ))
      .getSingleOrNull();
  if (drafting == null) {
    return;
  }

  final house = await (db.select(db.houseSync)
        ..where((t) => t.houseId.equals(houseId)))
      .getSingle();
  final settings = await (db.select(db.localUserSettings)).getSingleOrNull();
  final bumpOp = sync.opFactory.houseRulesVersionUpdate(
    opId: idGen.v4(),
    houseId: houseId,
    rulesVersion: house.rulesVersion + 1,
  );
  await sync.emitLocalOps(
    houseId: houseId,
    tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
    senderMemberId: senderMemberId,
    ops: [bumpOp],
  );
}
