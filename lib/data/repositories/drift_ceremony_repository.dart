import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/entities/cycle.dart';
import 'package:rumah/domain/entities/privilege_template.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/domain/repositories/ceremony_repository.dart';
import 'package:rumah/sync/ceremony_guardian.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/hlc.dart';
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
  Future<Cycle> startNextCycleCeremony({
    required String houseId,
    required String handoverCycleId,
    required String actorMemberId,
  }) async {
    final handoverRow = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(handoverCycleId)))
        .getSingleOrNull();
    if (handoverRow == null ||
        handoverRow.status != CycleStatus.handover.wireValue ||
        handoverRow.handoverStep != HandoverStep.retro.wireValue) {
      throw StateError('Handover cycle must be in retro step');
    }

    final existingDraft = await _findCycleByStatus(houseId, CycleStatus.drafting);
    if (existingDraft != null) {
      if (handoverRow.handoverStep == HandoverStep.retro.wireValue) {
        final advanceOp = _sync.opFactory.cycleHandoverStepAdvance(
          opId: _uuid.v4(),
          houseId: houseId,
          cycleId: handoverCycleId,
          actorMemberId: actorMemberId,
          from: HandoverStep.retro.wireValue,
          to: HandoverStep.ceremonyPending.wireValue,
        );
        await _emit(
          houseId: houseId,
          senderMemberId: actorMemberId,
          ops: [advanceOp],
        );
      }
      return _toCycle(existingDraft);
    }

    final cycleId = _uuid.v4();
    final createOp = _sync.opFactory.cycleCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      cycleId: cycleId,
      activeGuardianMemberId: handoverRow.activeGuardianMemberId,
    );
    final advanceOp = _sync.opFactory.cycleHandoverStepAdvance(
      opId: _uuid.v4(),
      houseId: houseId,
      cycleId: handoverCycleId,
      actorMemberId: actorMemberId,
      from: HandoverStep.retro.wireValue,
      to: HandoverStep.ceremonyPending.wireValue,
    );
    await _emit(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [createOp, advanceOp],
    );

    final row = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingle();
    return _toCycle(row);
  }

  @override
  Future<void> advanceHandoverStep({
    required String houseId,
    required String cycleId,
    required String actorMemberId,
    required String from,
    required String to,
  }) async {
    final op = _sync.opFactory.cycleHandoverStepAdvance(
      opId: _uuid.v4(),
      houseId: houseId,
      cycleId: cycleId,
      actorMemberId: actorMemberId,
      from: from,
      to: to,
    );
    await _emit(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [op],
    );
  }

  @override
  Future<void> expireCycleToHandover({
    required String houseId,
    required String cycleId,
  }) async {
    final op = _sync.opFactory.cycleStatusTransition(
      opId: _uuid.v4(),
      houseId: houseId,
      cycleId: cycleId,
      from: CycleStatus.active.wireValue,
      to: CycleStatus.handover.wireValue,
    );
    await _emit(houseId: houseId, senderMemberId: null, ops: [op]);
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
      startedAtHlc: row.startedAtHlc,
      endsAtHlc: row.endsAtHlc,
      cycleStartScoresJson: row.cycleStartScoresJson,
      handoverStep: row.handoverStep != null
          ? HandoverStep.fromWire(row.handoverStep!)
          : null,
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

/// Returns the guardian from the most recently completed cycle, if any.
Future<String?> findPreviousCycleGuardianId(
  AppDatabase db,
  String houseId,
) async {
  final rows = await (db.select(db.cyclesSync)
        ..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.status.equals(CycleStatus.completed.wireValue),
        ))
      .get();
  if (rows.isEmpty) {
    return null;
  }
  rows.sort((a, b) {
    final hlcA = HlcService.fromBytes(Uint8List.fromList(a.updatedAtHlc));
    final hlcB = HlcService.fromBytes(Uint8List.fromList(b.updatedAtHlc));
    return hlcA.compareTo(hlcB);
  });
  return rows.last.activeGuardianMemberId;
}

List<RotationRosterMember> _activeRotationRoster(
  List<HousematesSyncData> housemates,
) {
  return housemates
      .where((m) => m.memberStatus == MemberStatus.active.wireValue)
      .where((m) => m.rotationOrderIndex != null)
      .map(
        (m) => RotationRosterMember(
          memberId: m.memberId,
          rotationOrderIndex: m.rotationOrderIndex!,
        ),
      )
      .toList();
}

/// Activates a drafting cycle when all active members have accepted current rules.
Future<void> maybeActivateCycle({
  required AppDatabase db,
  required SyncWriteCoordinator sync,
  required String houseId,
  required String cycleId,
  Uuid? uuid,
}) async {
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

  await tryActivateCycleIfReady(
    db: db,
    sync: sync,
    houseId: houseId,
    cycleId: cycleId,
    housemates: housemates,
    activeIds: activeIds,
    uuid: uuid,
  );
}

/// Assigns a guardian and transitions the cycle to active when prerequisites are met.
Future<void> tryActivateCycleIfReady({
  required AppDatabase db,
  required SyncWriteCoordinator sync,
  required String houseId,
  required String cycleId,
  required List<HousematesSyncData> housemates,
  required List<String> activeIds,
  Uuid? uuid,
}) async {
  final idGen = uuid ?? const Uuid();
  final draftingRow = await (db.select(db.cyclesSync)
        ..where((t) => t.cycleId.equals(cycleId)))
      .getSingleOrNull();
  if (draftingRow == null ||
      draftingRow.status != CycleStatus.drafting.wireValue) {
    return;
  }

  final handoverRow = await (db.select(db.cyclesSync)
        ..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.status.equals(CycleStatus.handover.wireValue),
        ))
      .getSingleOrNull();

  final houseRow = await (db.select(db.houseSync)
        ..where((t) => t.houseId.equals(houseId)))
      .getSingleOrNull();
  final cycleDurationDays =
      houseRow?.cycleDurationDays ?? HandoverCycleHelpers.defaultCycleDurationDays;

  final ops = <SyncOperation>[];

  String? rotationSourceGuardianId;
  if (handoverRow != null) {
    rotationSourceGuardianId = handoverRow.activeGuardianMemberId;
  } else {
    rotationSourceGuardianId = await findPreviousCycleGuardianId(db, houseId);
  }

  if (rotationSourceGuardianId != null) {
    final hasNullRotationIndex = housemates
        .where((m) => m.memberStatus == MemberStatus.active.wireValue)
        .any((m) => m.rotationOrderIndex == null);
    if (hasNullRotationIndex) {
      return;
    }
  }

  int? previousGuardianRotationIndex;
  if (rotationSourceGuardianId != null) {
    final previousMate = housemates
        .where((m) => m.memberId == rotationSourceGuardianId)
        .firstOrNull;
    previousGuardianRotationIndex = previousMate?.rotationOrderIndex;
    if (previousGuardianRotationIndex == null) {
      return;
    }
  }

  final guardianId = resolveGuardianForActivation(
    cycleId: cycleId,
    activeMemberIds: activeIds,
    activeRotationRoster: _activeRotationRoster(housemates),
    previousCycleGuardianId: rotationSourceGuardianId,
    previousGuardianRotationIndex: previousGuardianRotationIndex,
  );

  ops.add(
    sync.opFactory.cycleGuardianUpdate(
      opId: idGen.v4(),
      houseId: houseId,
      cycleId: cycleId,
      activeGuardianMemberId: guardianId,
    ),
  );

  if (draftingRow.startedAtHlc == null || draftingRow.startedAtHlc!.isEmpty) {
    final startedHlc = sync.hlcService.now();
    final startedBytes = sync.hlcService.toBytes(startedHlc);
    final endsBytes = HandoverCycleHelpers.computeEndsAtHlc(
      startedAtHlc: startedBytes,
      cycleDurationDays: cycleDurationDays,
    );
    final scores = <String, int>{
      for (final mate in housemates
          .where((m) => m.memberStatus == MemberStatus.active.wireValue))
        mate.memberId: mate.lifetimeScore,
    };
    ops.add(
      sync.opFactory.cycleActivationFieldsSet(
        opId: idGen.v4(),
        houseId: houseId,
        cycleId: cycleId,
        startedAtHlc: base64Encode(startedBytes),
        endsAtHlc: base64Encode(endsBytes),
        cycleStartScores: scores,
      ),
    );
  }

  if (handoverRow != null) {
    ops.add(
      sync.opFactory.cycleStatusTransition(
        opId: idGen.v4(),
        houseId: houseId,
        cycleId: handoverRow.cycleId,
        from: CycleStatus.handover.wireValue,
        to: CycleStatus.completed.wireValue,
      ),
    );
  }

  ops.add(
    sync.opFactory.cycleStatusTransition(
      opId: idGen.v4(),
      houseId: houseId,
      cycleId: cycleId,
      from: CycleStatus.drafting.wireValue,
      to: CycleStatus.active.wireValue,
    ),
  );

  final settings =
      await (db.select(db.localUserSettings)).getSingleOrNull();
  await sync.emitLocalOps(
    houseId: houseId,
    tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
    senderMemberId: null,
    ops: ops,
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
