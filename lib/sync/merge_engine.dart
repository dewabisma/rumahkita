import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/ceremony_guardian.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/merge_context.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/state_machines/cycle_status_machine.dart';
import 'package:rumah/sync/state_machines/handover_step_machine.dart';
import 'package:rumah/sync/state_machines/member_status_machine.dart';
import 'package:rumah/sync/state_machines/proposal_status_machine.dart';
import 'package:rumah/sync/state_machines/task_status_machine.dart';
import 'package:rumah/sync/sync_operation.dart';

class LwwRegister {
  LwwRegister._();

  static bool shouldApply({
    required HybridLogicalClock incomingHlc,
    required String incomingDeviceId,
    required Uint8List? existingHlcBytes,
    required String? existingDeviceId,
  }) {
    if (existingHlcBytes == null || existingHlcBytes.isEmpty) {
      return true;
    }
    final existingHlc = HlcService.fromBytes(existingHlcBytes);
    final incumbentDevice = existingDeviceId ?? '';
    return HlcService.isNewer(
      incomingHlc,
      incomingDeviceId,
      existingHlc,
      incumbentDevice,
    );
  }
}

class OrMapVoteRegister {
  OrMapVoteRegister._();

  static String voteKey(String proposalId, String voterMemberId) =>
      '$proposalId|$voterMemberId';

  static String signoffKey(String memberId) => memberId;
}

class MergeEngine {
  MergeEngine(this._db);

  final AppDatabase _db;

  Future<MergeResult> applyOps(
    List<SyncOperation> ops,
    MergeContext context,
  ) async {
    final applied = <String>[];
    final rejected = <String>[];
    final sideEffects = <MergeSideEffect>[];

    await _db.transaction(() async {
      for (final op in ops) {
        if (context.isOpApplied(op.opId)) {
          continue;
        }

        final tombstone = context.checkTombstone(
          senderMemberId: context.senderMemberId,
          actorMemberId: op.actorMemberId,
          opType: op.opType,
        );
        if (!tombstone.allowed) {
          rejected.add(op.opId);
          continue;
        }

        final success = await _applySingle(op, context, sideEffects);
        if (success) {
          await _db
              .into(_db.syncAppliedOps)
              .insert(
                SyncAppliedOpsCompanion.insert(
                  opId: op.opId,
                  houseId: op.houseId,
                  appliedAtHlc: _decodeHlcBytes(op.hlc),
                ),
                mode: InsertMode.insertOrIgnore,
              );
          applied.add(op.opId);
          context.appliedOpIds.add(op.opId);
        } else {
          rejected.add(op.opId);
        }
      }
    });

    return MergeResult(
      appliedOpIds: applied,
      rejectedOpIds: rejected,
      sideEffects: sideEffects,
      error: ops.isNotEmpty && applied.isEmpty && rejected.isNotEmpty
          ? 'all ops rejected'
          : null,
    );
  }

  Future<bool> _applySingle(
    SyncOperation op,
    MergeContext context,
    List<MergeSideEffect> sideEffects,
  ) async {
    final type = SyncOpType.values
        .where((e) => e.wireValue == op.opType)
        .cast<SyncOpType?>()
        .firstWhere((e) => e != null, orElse: () => null);
    if (type == null) {
      return false;
    }

    switch (type) {
      case SyncOpType.houseCreate:
        return _applyHouseCreate(op);
      case SyncOpType.housemateCreate:
        return _applyHousemateCreate(op, sideEffects);
      case SyncOpType.houseDisplayNameUpdate:
        return _applyHouseDisplayNameUpdate(op);
      case SyncOpType.houseRulesVersionUpdate:
        return _applyHouseRulesVersionUpdate(op, sideEffects);
      case SyncOpType.housePrivilegeTemplatesUpdate:
        return _applyHousePrivilegeTemplatesUpdate(op);
      case SyncOpType.housemateNicknameUpdate:
        return _applyHousemateNicknameUpdate(op, context);
      case SyncOpType.memberStatusTransition:
        return _applyMemberStatusTransition(op, context);
      case SyncOpType.rotationAssignment:
        return _applyRotationAssignment(op);
      case SyncOpType.scoreEventAppend:
        return _applyScoreEvent(op, context, sideEffects);
      case SyncOpType.proposalCreate:
        return _applyProposalCreate(op, sideEffects);
      case SyncOpType.proposalStatusTransition:
        return _applyProposalStatusTransition(op, sideEffects);
      case SyncOpType.voteCast:
        return _applyVoteCast(op, context, sideEffects);
      case SyncOpType.cycleCreate:
        return _applyCycleCreate(op);
      case SyncOpType.cycleStatusTransition:
        return _applyCycleStatusTransition(op, sideEffects);
      case SyncOpType.cycleGuardianUpdate:
        return _applyCycleGuardianUpdate(op);
      case SyncOpType.cycleSignoffSet:
        return _applyCycleSignoffSet(op, sideEffects);
      case SyncOpType.cycleActivationFieldsSet:
        return _applyCycleActivationFieldsSet(op);
      case SyncOpType.cycleHandoverStepAdvance:
        return _applyCycleHandoverStepAdvance(op);
      case SyncOpType.taskCreate:
        return _applyTaskCreate(op);
      case SyncOpType.taskFieldUpdate:
        return _applyTaskFieldUpdate(op, context, sideEffects);
      case SyncOpType.taskClaim:
        return _applyTaskClaim(op, context);
      case SyncOpType.auditLogAppend:
        return _applyAuditLogAppend(op);
    }
  }

  Uint8List _decodeHlcBytes(String hlcBase64) {
    return Uint8List.fromList(base64Decode(hlcBase64));
  }

  HybridLogicalClock _decodeHlc(String hlcBase64) =>
      HlcService.fromBytes(_decodeHlcBytes(hlcBase64));

  Future<bool> _applyHouseCreate(SyncOperation op) async {
    final existing = await (_db.select(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).getSingleOrNull();
    if (existing != null) {
      return false;
    }
    final payload = op.payload;
    await _db
        .into(_db.houseSync)
        .insert(
          HouseSyncCompanion.insert(
            houseId: op.houseId,
            displayName: payload['display_name'] as String,
            creatorMemberId: payload['creator_member_id'] as String,
            rulesVersion: Value(payload['rules_version'] as int? ?? 0),
            createdAtHlc: _decodeHlcBytes(op.hlc),
            updatedAtHlc: _decodeHlcBytes(op.hlc),
            displayNameHlc: Value(_decodeHlcBytes(op.hlc)),
            displayNameDeviceId: Value(op.originDeviceId),
            rulesVersionHlc: Value(_decodeHlcBytes(op.hlc)),
            rulesVersionDeviceId: Value(op.originDeviceId),
          ),
        );
    return true;
  }

  Future<bool> _applyHousemateCreate(
    SyncOperation op,
    List<MergeSideEffect> sideEffects,
  ) async {
    final payload = op.payload;
    final memberId = payload['member_id'] as String;
    final existing =
        await (_db.select(_db.housematesSync)
              ..where((t) => t.memberId.equals(memberId)))
            .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    final nodeKey = payload['tailscale_node_key'] as String;
    await _db
        .into(_db.housematesSync)
        .insert(
          HousematesSyncCompanion.insert(
            memberId: memberId,
            houseId: op.houseId,
            tailscaleUserId: payload['tailscale_user_id'] as String,
            tailscaleNodeKey: nodeKey,
            nickname: payload['nickname'] as String,
            rotationOrderIndex: Value(payload['rotation_order_index'] as int?),
            memberStatus: (payload['member_status'] as String?) ?? 'active',
            updatedAtHlc: _decodeHlcBytes(op.hlc),
          ),
        );
    await _db
        .into(_db.syncPeerAllowlist)
        .insert(
          SyncPeerAllowlistCompanion.insert(
            tailscaleNodeKey: nodeKey,
            houseId: op.houseId,
            memberId: Value(memberId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    sideEffects.add(
      HousemateJoined(
        houseId: op.houseId,
        memberId: memberId,
        tailscaleNodeKey: nodeKey,
        hlc: _decodeHlcBytes(op.hlc),
      ),
    );
    return true;
  }

  Future<bool> _applyHouseDisplayNameUpdate(SyncOperation op) async {
    final row = await (_db.select(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.displayNameHlc,
      existingDeviceId: row.displayNameDeviceId,
    )) {
      return false;
    }
    await (_db.update(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).write(
      HouseSyncCompanion(
        displayName: Value(op.payload['display_name'] as String),
        displayNameHlc: Value(_decodeHlcBytes(op.hlc)),
        displayNameDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyHouseRulesVersionUpdate(
    SyncOperation op,
    List<MergeSideEffect> sideEffects,
  ) async {
    final row = await (_db.select(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.rulesVersionHlc,
      existingDeviceId: row.rulesVersionDeviceId,
    )) {
      return false;
    }
    final newVersion = op.payload['rules_version'] as int;
    sideEffects.add(
      RulesVersionBumped(
        houseId: op.houseId,
        oldVersion: row.rulesVersion,
        newVersion: newVersion,
        hlc: _decodeHlcBytes(op.hlc),
      ),
    );
    await (_db.update(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).write(
      HouseSyncCompanion(
        rulesVersion: Value(newVersion),
        rulesVersionHlc: Value(_decodeHlcBytes(op.hlc)),
        rulesVersionDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyHousePrivilegeTemplatesUpdate(SyncOperation op) async {
    final row = await (_db.select(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.privilegeTemplatesHlc,
      existingDeviceId: row.privilegeTemplatesDeviceId,
    )) {
      return false;
    }
    final templates = op.payload['privilege_templates'] as Map<String, dynamic>;
    await (_db.update(
      _db.houseSync,
    )..where((t) => t.houseId.equals(op.houseId))).write(
      HouseSyncCompanion(
        privilegeTemplates: Value(jsonEncode(templates)),
        privilegeTemplatesHlc: Value(_decodeHlcBytes(op.hlc)),
        privilegeTemplatesDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyHousemateNicknameUpdate(
    SyncOperation op,
    MergeContext context,
  ) async {
    final memberId = op.payload['member_id'] as String;
    if (!context.isMemberActive(memberId)) {
      return false;
    }
    final row = await (_db.select(
      _db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.nicknameHlc,
      existingDeviceId: row.nicknameDeviceId,
    )) {
      return false;
    }
    await (_db.update(
      _db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).write(
      HousematesSyncCompanion(
        nickname: Value(op.payload['nickname'] as String),
        nicknameHlc: Value(_decodeHlcBytes(op.hlc)),
        nicknameDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyMemberStatusTransition(
    SyncOperation op,
    MergeContext context,
  ) async {
    final memberId = op.payload['member_id'] as String;
    final from = op.payload['from'] != null
        ? MemberStatus.fromWire(op.payload['from'] as String)
        : null;
    final to = MemberStatus.fromWire(op.payload['to'] as String);
    final row = await (_db.select(
      _db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).getSingleOrNull();
    final current = row != null
        ? MemberStatus.fromWire(row.memberStatus)
        : null;
    if (from != null && current != from) {
      return false;
    }
    if (!MemberStatusMachine.canTransition(current, to)) {
      return false;
    }
    if (context.isMemberEvicted(memberId) &&
        !MemberStatusMachine.isExecutionTransition(
          current ?? MemberStatus.active,
          to,
        )) {
      return false;
    }
    await (_db.update(
      _db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).write(
      HousematesSyncCompanion(
        memberStatus: Value(to.wireValue),
        evictedAtHlc: to == MemberStatus.evicted
            ? Value(_decodeHlcBytes(op.hlc))
            : const Value.absent(),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    context.memberStatusById[memberId] = to;
    return true;
  }

  Future<bool> _applyRotationAssignment(SyncOperation op) async {
    final memberId = op.payload['member_id'] as String;
    final row = await (_db.select(
      _db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (row.rotationOrderIndex != null) {
      return false;
    }
    await (_db.update(
      _db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).write(
      HousematesSyncCompanion(
        rotationOrderIndex: Value(op.payload['rotation_order_index'] as int),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyScoreEvent(
    SyncOperation op,
    MergeContext context,
    List<MergeSideEffect> sideEffects,
  ) async {
    final memberId = op.payload['member_id'] as String;
    if (!context.isMemberActive(memberId)) {
      return false;
    }
    final reasonRef = op.payload['reason_ref'] as String?;
    if (HandoverCycleHelpers.isTaskApproveScoreEvent(reasonRef)) {
      final taskId = reasonRef!.split(':').last;
      final taskRow = await (_db.select(_db.tasksSync)
            ..where((t) => t.taskId.equals(taskId)))
          .getSingleOrNull();
      if (taskRow == null) {
        return false;
      }
      final cycleRow = await (_db.select(_db.cyclesSync)
            ..where((t) => t.cycleId.equals(taskRow.cycleId)))
          .getSingleOrNull();
      if (cycleRow == null) {
        return false;
      }
      if (HandoverCycleHelpers.isHandoverCycle(cycleRow.status) &&
          !HandoverCycleHelpers.allowsTaskApproveOnHandover(
            cycleRow.handoverStep,
          )) {
        return false;
      }
    }
    final eventId = op.payload['event_id'] as String;
    final memberRow = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingleOrNull();
    final oldScore = memberRow?.lifetimeScore ?? 0;
    final inserted = await _db
        .into(_db.scoreEvents)
        .insert(
          ScoreEventsCompanion.insert(
            eventId: eventId,
            houseId: op.houseId,
            memberId: memberId,
            delta: op.payload['delta'] as int,
            reasonRef: Value(op.payload['reason_ref'] as String?),
            hlc: _decodeHlcBytes(op.hlc),
            actorDeviceId: op.originDeviceId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (inserted == 0) {
      return false;
    }
    await _reprojectLifetimeScore(memberId);
    if (memberRow == null) {
      return true;
    }
    final updatedRow = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingleOrNull();
    final newScore = updatedRow?.lifetimeScore ?? oldScore;
    if (oldScore != newScore) {
      sideEffects.add(
        ScoreChanged(
          houseId: op.houseId,
          memberId: memberId,
          oldScore: oldScore,
          newScore: newScore,
          triggeringEventId: eventId,
          hlc: _decodeHlcBytes(op.hlc),
        ),
      );
    }
    return true;
  }

  Future<void> _reprojectLifetimeScore(String memberId) async {
    final events = await (_db.select(
      _db.scoreEvents,
    )..where((t) => t.memberId.equals(memberId))).get();
    final sum = events.fold<int>(0, (acc, e) => acc + e.delta);
    await (_db.update(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .write(HousematesSyncCompanion(lifetimeScore: Value(sum)));
  }

  Future<bool> _applyProposalCreate(
    SyncOperation op,
    List<MergeSideEffect> sideEffects,
  ) async {
    final proposalId = op.payload['proposal_id'] as String;
    final existing = await (_db.select(
      _db.removalProposalsSync,
    )..where((t) => t.proposalId.equals(proposalId))).getSingleOrNull();
    if (existing != null) {
      return false;
    }
    final createdAtHlc = _decodeHlcBytes(op.hlc);
    Uint8List? votingWindowEndsAtHlc;
    final payloadEnds = op.payload['voting_window_ends_at_hlc'] as String?;
    if (payloadEnds != null) {
      votingWindowEndsAtHlc = _decodeHlcBytes(payloadEnds);
    } else {
      votingWindowEndsAtHlc = HandoverCycleHelpers.computeEndsAtHlc(
        startedAtHlc: createdAtHlc,
        cycleDurationDays: 7,
      );
    }
    await _db
        .into(_db.removalProposalsSync)
        .insert(
          RemovalProposalsSyncCompanion.insert(
            proposalId: proposalId,
            houseId: op.houseId,
            targetMemberId: op.payload['target_member_id'] as String,
            proposerMemberId: Value(
              op.payload['proposer_member_id'] as String?,
            ),
            type: op.payload['type'] as String,
            status: (op.payload['status'] as String?) ?? 'proposed',
            createdAtHlc: createdAtHlc,
            updatedAtHlc: createdAtHlc,
            votingWindowEndsAtHlc: Value(votingWindowEndsAtHlc),
          ),
        );
    sideEffects.add(
      ProposalCreated(
        houseId: op.houseId,
        proposalId: proposalId,
        targetMemberId: op.payload['target_member_id'] as String,
        proposerMemberId: op.payload['proposer_member_id'] as String?,
        type: op.payload['type'] as String,
        justificationNotes: op.payload['justification_notes'] as String?,
        hlc: _decodeHlcBytes(op.hlc),
      ),
    );
    return true;
  }

  Future<bool> _applyProposalStatusTransition(
    SyncOperation op,
    List<MergeSideEffect> sideEffects,
  ) async {
    final proposalId = op.payload['proposal_id'] as String;
    final from = op.payload['from'] != null
        ? ProposalStatus.fromWire(op.payload['from'] as String)
        : null;
    final to = ProposalStatus.fromWire(op.payload['to'] as String);
    final row = await (_db.select(
      _db.removalProposalsSync,
    )..where((t) => t.proposalId.equals(proposalId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    final current = ProposalStatus.fromWire(row.status);
    if (from != null && current != from) {
      return false;
    }
    if (!ProposalStatusMachine.canTransition(current, to) &&
        !(from == ProposalStatus.proposed &&
            ProposalStatusMachine.isSelfRemovalShortcut(from, to))) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.statusHlc,
      existingDeviceId: row.statusDeviceId,
    )) {
      return false;
    }
    await (_db.update(
      _db.removalProposalsSync,
    )..where((t) => t.proposalId.equals(proposalId))).write(
      RemovalProposalsSyncCompanion(
        status: Value(to.wireValue),
        statusHlc: Value(_decodeHlcBytes(op.hlc)),
        statusDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    sideEffects.add(
      ProposalStatusChanged(
        houseId: op.houseId,
        proposalId: proposalId,
        from: from?.wireValue,
        to: to.wireValue,
        targetMemberId: row.targetMemberId,
        type: row.type,
        hlc: _decodeHlcBytes(op.hlc),
      ),
    );
    if (to == ProposalStatus.readyToExecute) {
      final target = await (_db.select(_db.housematesSync)
            ..where((t) => t.memberId.equals(row.targetMemberId)))
          .getSingleOrNull();
      if (target != null) {
        sideEffects.add(
          RemovalReadyToExecute(
            houseId: op.houseId,
            proposalId: proposalId,
            targetMemberId: row.targetMemberId,
            targetNodeKey: target.tailscaleNodeKey,
            hlc: _decodeHlcBytes(op.hlc),
          ),
        );
      }
    }
    return true;
  }

  Future<bool> _applyVoteCast(
    SyncOperation op,
    MergeContext context,
    List<MergeSideEffect> sideEffects,
  ) async {
    final voterId = op.payload['voter_member_id'] as String;
    if (!context.isMemberActive(voterId)) {
      return false;
    }
    final proposalId = op.payload['proposal_id'] as String;
    final voteId = op.payload['vote_id'] as String;
    final existingVotes =
        await (_db.select(_db.proposalVotesSync)..where(
              (t) =>
                  t.proposalId.equals(proposalId) &
                  t.voterMemberId.equals(voterId),
            ))
            .get();
    if (existingVotes.isNotEmpty) {
      final incumbent = existingVotes.first;
      if (!LwwRegister.shouldApply(
        incomingHlc: _decodeHlc(op.hlc),
        incomingDeviceId: op.originDeviceId,
        existingHlcBytes: incumbent.hlc,
        existingDeviceId: incumbent.originDeviceId,
      )) {
        return false;
      }
      await (_db.delete(
        _db.proposalVotesSync,
      )..where((t) => t.voteId.equals(incumbent.voteId))).go();
    }
    await _db
        .into(_db.proposalVotesSync)
        .insert(
          ProposalVotesSyncCompanion.insert(
            voteId: voteId,
            houseId: op.houseId,
            proposalId: proposalId,
            voterMemberId: voterId,
            voteCast: (op.payload['vote_cast'] as bool) ? 1 : 0,
            hlc: _decodeHlcBytes(op.hlc),
            originDeviceId: Value(op.originDeviceId),
          ),
        );
    sideEffects.add(
      VoteCastApplied(
        houseId: op.houseId,
        proposalId: proposalId,
        voterMemberId: voterId,
        voteCast: op.payload['vote_cast'] as bool,
        hlc: _decodeHlcBytes(op.hlc),
      ),
    );
    return true;
  }

  Future<bool> _applyCycleCreate(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final existing = await (_db.select(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingleOrNull();
    if (existing != null) {
      return false;
    }
    final draftingRows =
        await (_db.select(_db.cyclesSync)..where(
              (t) =>
                  t.houseId.equals(op.houseId) &
                  t.status.equals(CycleStatus.drafting.wireValue),
            ))
            .get();
    if (draftingRows.isNotEmpty) {
      return false;
    }
    final liveRows = await (_db.select(_db.cyclesSync)..where(
          (t) =>
              t.houseId.equals(op.houseId) &
              (t.status.equals(CycleStatus.active.wireValue) |
                  t.status.equals(CycleStatus.handover.wireValue)),
        ))
        .get();
    if (liveRows.any((r) => r.status == CycleStatus.active.wireValue)) {
      return false;
    }
    final handoverRows = liveRows
        .where((r) => r.status == CycleStatus.handover.wireValue)
        .toList();
    if (handoverRows.isNotEmpty) {
      final rolloverReady = handoverRows.every(
        (r) => r.handoverStep == HandoverStep.retro.wireValue,
      );
      if (!rolloverReady) {
        return false;
      }
    }
    await _db
        .into(_db.cyclesSync)
        .insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: op.houseId,
            activeGuardianMemberId:
                op.payload['active_guardian_member_id'] as String,
            status: (op.payload['status'] as String?) ?? 'drafting',
            updatedAtHlc: _decodeHlcBytes(op.hlc),
          ),
        );
    return true;
  }

  Future<bool> _applyCycleStatusTransition(
    SyncOperation op,
    List<MergeSideEffect> sideEffects,
  ) async {
    final cycleId = op.payload['cycle_id'] as String;
    final from = op.payload['from'] != null
        ? CycleStatus.fromWire(op.payload['from'] as String)
        : null;
    final to = CycleStatus.fromWire(op.payload['to'] as String);
    final row = await (_db.select(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    final current = CycleStatus.fromWire(row.status);
    if (from != null && current != from) {
      return false;
    }
    if (!CycleStatusMachine.canTransition(current, to)) {
      return false;
    }
    if (current == CycleStatus.active && to == CycleStatus.handover) {
      if (HandoverCycleHelpers.isOpHlcBeforeEndsAt(
        opHlcBase64: op.hlc,
        endsAtHlcBytes: row.endsAtHlc,
      )) {
        return false;
      }
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.statusHlc,
      existingDeviceId: row.statusDeviceId,
    )) {
      return false;
    }
    final companion = CyclesSyncCompanion(
      status: Value(to.wireValue),
      statusHlc: Value(_decodeHlcBytes(op.hlc)),
      statusDeviceId: Value(op.originDeviceId),
      updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
    );
    if (to == CycleStatus.handover) {
      await (_db.update(
        _db.cyclesSync,
      )..where((t) => t.cycleId.equals(cycleId))).write(
        companion.copyWith(
          handoverStep: const Value('closeout'),
          handoverStepHlc: Value(_decodeHlcBytes(op.hlc)),
          handoverStepDeviceId: Value(op.originDeviceId),
        ),
      );
      sideEffects.add(
        HandoverStarted(
          houseId: op.houseId,
          cycleId: cycleId,
          guardianMemberId: row.activeGuardianMemberId,
          hlc: _decodeHlcBytes(op.hlc),
        ),
      );
      return true;
    }
    await (_db.update(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).write(companion);
    return true;
  }

  Future<bool> _applyCycleActivationFieldsSet(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final row = await (_db.select(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (row.status != CycleStatus.drafting.wireValue) {
      return false;
    }
    if (row.startedAtHlc != null && row.startedAtHlc!.isNotEmpty) {
      return false;
    }
    final startedAt = _decodeHlcBytes(op.payload['started_at_hlc'] as String);
    final endsAt = _decodeHlcBytes(op.payload['ends_at_hlc'] as String);
    final scoresJson = jsonEncode(
      op.payload['cycle_start_scores_json'] as Map<String, dynamic>,
    );
    await (_db.update(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).write(
      CyclesSyncCompanion(
        startedAtHlc: Value(startedAt),
        endsAtHlc: Value(endsAt),
        cycleStartScoresJson: Value(scoresJson),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyCycleHandoverStepAdvance(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final from = HandoverStep.fromWire(op.payload['from'] as String);
    final to = HandoverStep.fromWire(op.payload['to'] as String);
    final row = await (_db.select(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingleOrNull();
    if (row == null || row.status != CycleStatus.handover.wireValue) {
      return false;
    }
    final current = row.handoverStep != null
        ? HandoverStep.fromWire(row.handoverStep!)
        : HandoverStep.closeout;
    if (current != from) {
      return false;
    }
    if (!HandoverStepMachine.canTransition(current, to)) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.handoverStepHlc,
      existingDeviceId: row.handoverStepDeviceId,
    )) {
      return false;
    }
    if (to == HandoverStep.retro) {
      final tasks = await (_db.select(_db.tasksSync)
            ..where((t) => t.cycleId.equals(cycleId)))
          .get();
      if (HandoverCycleHelpers.cycleHasPendingReviewTasks(
        cycleId: cycleId,
        tasks: tasks.map((t) => (cycleId: t.cycleId, status: t.status)),
      )) {
        return false;
      }
    }
    if (to == HandoverStep.ceremonyPending) {
      final actorId = op.actorMemberId;
      if (actorId == null || actorId != row.activeGuardianMemberId) {
        return false;
      }
    }
    await (_db.update(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).write(
      CyclesSyncCompanion(
        handoverStep: Value(to.wireValue),
        handoverStepHlc: Value(_decodeHlcBytes(op.hlc)),
        handoverStepDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyCycleGuardianUpdate(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final row = await (_db.select(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.guardianHlc,
      existingDeviceId: row.guardianDeviceId,
    )) {
      return false;
    }
    await (_db.update(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).write(
      CyclesSyncCompanion(
        activeGuardianMemberId: Value(
          op.payload['active_guardian_member_id'] as String,
        ),
        guardianHlc: Value(_decodeHlcBytes(op.hlc)),
        guardianDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyCycleSignoffSet(
    SyncOperation op,
    List<MergeSideEffect> sideEffects,
  ) async {
    final cycleId = op.payload['cycle_id'] as String;
    final memberId = op.payload['member_id'] as String;
    final row = await (_db.select(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    final signoffs = Map<String, dynamic>.from(
      jsonDecode(row.ceremonySignoffs) as Map,
    );
    final existingEntry = signoffs[memberId];
    if (existingEntry is Map) {
      final existingHlc = existingEntry['hlc'] as String?;
      if (existingHlc != null &&
          !LwwRegister.shouldApply(
            incomingHlc: _decodeHlc(op.hlc),
            incomingDeviceId: op.originDeviceId,
            existingHlcBytes: _decodeHlcBytes(existingHlc),
            existingDeviceId: existingEntry['device_id'] as String?,
          )) {
        return false;
      }
    }
    signoffs[memberId] = {
      'accepted': op.payload['accepted'] as bool,
      'hlc': op.hlc,
      'device_id': op.originDeviceId,
    };
    await (_db.update(
      _db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).write(
      CyclesSyncCompanion(
        ceremonySignoffs: Value(jsonEncode(signoffs)),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    sideEffects.add(
      CeremonySignoffsChanged(houseId: op.houseId, cycleId: cycleId),
    );
    return true;
  }

  Future<bool> _applyTaskCreate(SyncOperation op) async {
    final taskId = op.payload['task_id'] as String;
    final cycleId = op.payload['cycle_id'] as String;
    final cycleRow = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingleOrNull();
    if (cycleRow != null &&
        HandoverCycleHelpers.isHandoverCycle(cycleRow.status)) {
      return false;
    }
    final existing = await (_db.select(
      _db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingleOrNull();
    if (existing != null) {
      return false;
    }
    await _db
        .into(_db.tasksSync)
        .insert(
          TasksSyncCompanion.insert(
            taskId: taskId,
            houseId: op.houseId,
            cycleId: op.payload['cycle_id'] as String,
            title: op.payload['title'] as String,
            negotiatedPoints: op.payload['negotiated_points'] as int,
            status: (op.payload['status'] as String?) ?? 'open',
            updatedAtHlc: _decodeHlcBytes(op.hlc),
          ),
        );
    return true;
  }

  Future<bool> _applyTaskFieldUpdate(
    SyncOperation op,
    MergeContext context,
    List<MergeSideEffect> sideEffects,
  ) async {
    final taskId = op.payload['task_id'] as String;
    final row = await (_db.select(
      _db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    final cycleRow = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(row.cycleId)))
        .getSingleOrNull();
    final field = op.payload['field'] as String;
    if (cycleRow != null &&
        HandoverCycleHelpers.isHandoverCycle(cycleRow.status) &&
        field != 'status') {
      return false;
    }
    final incomingHlc = _decodeHlc(op.hlc);
    final hlcBytes = _decodeHlcBytes(op.hlc);
    TasksSyncCompanion updateCompanion;
    switch (field) {
      case 'title':
        if (!LwwRegister.shouldApply(
          incomingHlc: incomingHlc,
          incomingDeviceId: op.originDeviceId,
          existingHlcBytes: row.titleHlc,
          existingDeviceId: row.titleDeviceId,
        )) {
          return false;
        }
        updateCompanion = TasksSyncCompanion(
          title: Value(op.payload['value'] as String),
          titleHlc: Value(hlcBytes),
          titleDeviceId: Value(op.originDeviceId),
          updatedAtHlc: Value(hlcBytes),
        );
      case 'negotiated_points':
        if (!LwwRegister.shouldApply(
          incomingHlc: incomingHlc,
          incomingDeviceId: op.originDeviceId,
          existingHlcBytes: row.pointsHlc,
          existingDeviceId: row.pointsDeviceId,
        )) {
          return false;
        }
        final newPoints = op.payload['value'] as int;
        sideEffects.add(
          TaskPointsChanged(
            taskId: taskId,
            cycleId: row.cycleId,
            oldPoints: row.negotiatedPoints,
            newPoints: newPoints,
            hlc: hlcBytes,
          ),
        );
        updateCompanion = TasksSyncCompanion(
          negotiatedPoints: Value(newPoints),
          pointsHlc: Value(hlcBytes),
          pointsDeviceId: Value(op.originDeviceId),
          updatedAtHlc: Value(hlcBytes),
        );
      case 'status':
        final to = TaskStatus.fromWire(op.payload['value'] as String);
        final current = TaskStatus.fromWire(row.status);
        final fromWire = op.payload['from'] as String?;
        if (fromWire != null && TaskStatus.fromWire(fromWire) != current) {
          return false;
        }
        if (!TaskStatusMachine.canTransition(current, to)) {
          return false;
        }
        if (cycleRow != null &&
            HandoverCycleHelpers.isHandoverCycle(cycleRow.status)) {
          if (to == TaskStatus.pendingReview) {
            return false;
          }
          if ((to == TaskStatus.approved || to == TaskStatus.open) &&
              current == TaskStatus.pendingReview &&
              !HandoverCycleHelpers.allowsTaskApproveOnHandover(
                cycleRow.handoverStep,
              )) {
            return false;
          }
        }
        if (to == TaskStatus.pendingReview && current == TaskStatus.open) {
          final actorId = op.actorMemberId;
          if (actorId == null || !context.isMemberActive(actorId)) {
            return false;
          }
          final claimed = (jsonDecode(row.claimedByMemberIds) as List<dynamic>)
              .cast<String>();
          if (!claimed.contains(actorId)) {
            return false;
          }
        }
        if (current == TaskStatus.pendingReview &&
            (to == TaskStatus.open || to == TaskStatus.approved)) {
          final actorId = op.actorMemberId;
          if (actorId == null || !context.isMemberActive(actorId)) {
            return false;
          }
          if (cycleRow == null ||
              !isTaskReviewGuardian(
                activeGuardianMemberId: cycleRow.activeGuardianMemberId,
                actorMemberId: actorId,
              )) {
            return false;
          }
        }
        if (!LwwRegister.shouldApply(
          incomingHlc: incomingHlc,
          incomingDeviceId: op.originDeviceId,
          existingHlcBytes: row.statusHlc,
          existingDeviceId: row.statusDeviceId,
        )) {
          return false;
        }
        if (to == TaskStatus.approved && current == TaskStatus.pendingReview) {
          final claimed = (jsonDecode(row.claimedByMemberIds) as List<dynamic>)
              .cast<String>();
          sideEffects.add(
            TaskApproved(
              houseId: op.houseId,
              taskId: taskId,
              cycleId: row.cycleId,
              negotiatedPoints: row.negotiatedPoints,
              claimedByMemberIds: claimed,
              hlc: hlcBytes,
            ),
          );
        }
        updateCompanion = TasksSyncCompanion(
          status: Value(to.wireValue),
          statusHlc: Value(hlcBytes),
          statusDeviceId: Value(op.originDeviceId),
          updatedAtHlc: Value(hlcBytes),
        );
      default:
        return false;
    }
    await (_db.update(
      _db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).write(updateCompanion);
    return true;
  }

  Future<bool> _applyTaskClaim(SyncOperation op, MergeContext context) async {
    final taskId = op.payload['task_id'] as String;
    final memberId = op.payload['member_id'] as String;
    if (!context.isMemberActive(memberId)) {
      return false;
    }
    final row = await (_db.select(
      _db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingleOrNull();
    if (row == null) {
      return false;
    }
    final cycleRow = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(row.cycleId)))
        .getSingleOrNull();
    if (cycleRow != null &&
        HandoverCycleHelpers.isHandoverCycle(cycleRow.status)) {
      return false;
    }
    if (TaskStatus.fromWire(row.status) != TaskStatus.open) {
      return false;
    }
    final existingClaims = await (_db.select(
      _db.taskClaimEvents,
    )..where((t) => t.taskId.equals(taskId))).get();
    if (existingClaims.isNotEmpty) {
      return false;
    }
    final eventId = op.payload['event_id'] as String;
    final inserted = await _db
        .into(_db.taskClaimEvents)
        .insert(
          TaskClaimEventsCompanion.insert(
            eventId: eventId,
            houseId: op.houseId,
            taskId: op.payload['task_id'] as String,
            memberId: op.payload['member_id'] as String,
            hlc: _decodeHlcBytes(op.hlc),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (inserted == 0) {
      return false;
    }
    await _reprojectTaskClaims(op.payload['task_id'] as String);
    return true;
  }

  Future<void> _reprojectTaskClaims(String taskId) async {
    final events = await (_db.select(
      _db.taskClaimEvents,
    )..where((t) => t.taskId.equals(taskId))).get();
    final memberIds = events.map((e) => e.memberId).toSet().toList();
    await (_db.update(
      _db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).write(
      TasksSyncCompanion(claimedByMemberIds: Value(jsonEncode(memberIds))),
    );
  }

  Future<bool> _applyAuditLogAppend(SyncOperation op) async {
    final logId = op.payload['log_id'] as String;
    final inserted = await _db
        .into(_db.auditLogAppendOnly)
        .insert(
          AuditLogAppendOnlyCompanion.insert(
            logId: logId,
            houseId: op.houseId,
            taskId: op.payload['task_id'] as String,
            actorMemberId: op.payload['actor_member_id'] as String,
            action: op.payload['action'] as String,
            justificationNotes: Value(
              op.payload['justification_notes'] as String?,
            ),
            hlc: _decodeHlcBytes(op.hlc),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return inserted > 0;
  }

  String payloadString(SyncOperation op, String key) =>
      op.payload[key] as String;
}
