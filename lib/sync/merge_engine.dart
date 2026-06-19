import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/merge_context.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/state_machines/cycle_status_machine.dart';
import 'package:rumah/sync/state_machines/member_status_machine.dart';
import 'package:rumah/sync/state_machines/proposal_status_machine.dart';
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
          await _db.into(_db.syncAppliedOps).insert(
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
        return _applyHousemateCreate(op);
      case SyncOpType.houseDisplayNameUpdate:
        return _applyHouseDisplayNameUpdate(op);
      case SyncOpType.houseRulesVersionUpdate:
        return _applyHouseRulesVersionUpdate(op, sideEffects);
      case SyncOpType.housemateNicknameUpdate:
        return _applyHousemateNicknameUpdate(op, context);
      case SyncOpType.memberStatusTransition:
        return _applyMemberStatusTransition(op, context);
      case SyncOpType.rotationAssignment:
        return _applyRotationAssignment(op);
      case SyncOpType.scoreEventAppend:
        return _applyScoreEvent(op, context);
      case SyncOpType.proposalCreate:
        return _applyProposalCreate(op);
      case SyncOpType.proposalStatusTransition:
        return _applyProposalStatusTransition(op);
      case SyncOpType.voteCast:
        return _applyVoteCast(op, context);
      case SyncOpType.cycleCreate:
        return _applyCycleCreate(op);
      case SyncOpType.cycleStatusTransition:
        return _applyCycleStatusTransition(op);
      case SyncOpType.cycleGuardianUpdate:
        return _applyCycleGuardianUpdate(op);
      case SyncOpType.cycleSignoffSet:
        return _applyCycleSignoffSet(op);
      case SyncOpType.taskCreate:
        return _applyTaskCreate(op);
      case SyncOpType.taskFieldUpdate:
        return _applyTaskFieldUpdate(op, sideEffects);
      case SyncOpType.taskClaim:
        return _applyTaskClaim(op);
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
    final existing = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(op.houseId)))
        .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    final payload = op.payload;
    await _db.into(_db.houseSync).insert(
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

  Future<bool> _applyHousemateCreate(SyncOperation op) async {
    final payload = op.payload;
    final existing = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(payload['member_id'] as String)))
        .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    await _db.into(_db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: payload['member_id'] as String,
            houseId: op.houseId,
            tailscaleUserId: payload['tailscale_user_id'] as String,
            tailscaleNodeKey: payload['tailscale_node_key'] as String,
            nickname: payload['nickname'] as String,
            rotationOrderIndex: Value(payload['rotation_order_index'] as int?),
            memberStatus: (payload['member_status'] as String?) ?? 'active',
            updatedAtHlc: _decodeHlcBytes(op.hlc),
          ),
        );
    await _db.into(_db.syncPeerAllowlist).insert(
          SyncPeerAllowlistCompanion.insert(
            tailscaleNodeKey: payload['tailscale_node_key'] as String,
            houseId: op.houseId,
            memberId: Value(payload['member_id'] as String),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return true;
  }

  Future<bool> _applyHouseDisplayNameUpdate(SyncOperation op) async {
    final row = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(op.houseId)))
        .getSingleOrNull();
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
    await (_db.update(_db.houseSync)
          ..where((t) => t.houseId.equals(op.houseId)))
        .write(
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
    final row = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(op.houseId)))
        .getSingleOrNull();
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
    await (_db.update(_db.houseSync)
          ..where((t) => t.houseId.equals(op.houseId)))
        .write(
      HouseSyncCompanion(
        rulesVersion: Value(newVersion),
        rulesVersionHlc: Value(_decodeHlcBytes(op.hlc)),
        rulesVersionDeviceId: Value(op.originDeviceId),
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
    final row = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingleOrNull();
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
    await (_db.update(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .write(
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
    final row = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingleOrNull();
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
    await (_db.update(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .write(
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
    final row = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingleOrNull();
    if (row == null) {
      return false;
    }
    if (row.rotationOrderIndex != null) {
      return false;
    }
    await (_db.update(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .write(
      HousematesSyncCompanion(
        rotationOrderIndex:
            Value(op.payload['rotation_order_index'] as int),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyScoreEvent(
    SyncOperation op,
    MergeContext context,
  ) async {
    final memberId = op.payload['member_id'] as String;
    if (!context.isMemberActive(memberId)) {
      return false;
    }
    final eventId = op.payload['event_id'] as String;
    final inserted = await _db.into(_db.scoreEvents).insert(
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
    return true;
  }

  Future<void> _reprojectLifetimeScore(String memberId) async {
    final events = await (_db.select(_db.scoreEvents)
          ..where((t) => t.memberId.equals(memberId)))
        .get();
    final sum = events.fold<int>(0, (acc, e) => acc + e.delta);
    await (_db.update(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .write(HousematesSyncCompanion(lifetimeScore: Value(sum)));
  }

  Future<bool> _applyProposalCreate(SyncOperation op) async {
    final proposalId = op.payload['proposal_id'] as String;
    final existing = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    await _db.into(_db.removalProposalsSync).insert(
          RemovalProposalsSyncCompanion.insert(
            proposalId: proposalId,
            houseId: op.houseId,
            targetMemberId: op.payload['target_member_id'] as String,
            proposerMemberId:
                Value(op.payload['proposer_member_id'] as String?),
            type: op.payload['type'] as String,
            status: (op.payload['status'] as String?) ?? 'proposed',
            createdAtHlc: _decodeHlcBytes(op.hlc),
            updatedAtHlc: _decodeHlcBytes(op.hlc),
          ),
        );
    return true;
  }

  Future<bool> _applyProposalStatusTransition(SyncOperation op) async {
    final proposalId = op.payload['proposal_id'] as String;
    final from = op.payload['from'] != null
        ? ProposalStatus.fromWire(op.payload['from'] as String)
        : null;
    final to = ProposalStatus.fromWire(op.payload['to'] as String);
    final row = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingleOrNull();
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
    await (_db.update(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .write(
      RemovalProposalsSyncCompanion(
        status: Value(to.wireValue),
        statusHlc: Value(_decodeHlcBytes(op.hlc)),
        statusDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyVoteCast(
    SyncOperation op,
    MergeContext context,
  ) async {
    final voterId = op.payload['voter_member_id'] as String;
    if (!context.isMemberActive(voterId)) {
      return false;
    }
    final proposalId = op.payload['proposal_id'] as String;
    final voteId = op.payload['vote_id'] as String;
    final existingVotes = await (_db.select(_db.proposalVotesSync)
          ..where(
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
      await (_db.delete(_db.proposalVotesSync)
            ..where((t) => t.voteId.equals(incumbent.voteId)))
          .go();
    }
    await _db.into(_db.proposalVotesSync).insert(
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
    return true;
  }

  Future<bool> _applyCycleCreate(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final existing = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    await _db.into(_db.cyclesSync).insert(
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

  Future<bool> _applyCycleStatusTransition(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final from = op.payload['from'] != null
        ? CycleStatus.fromWire(op.payload['from'] as String)
        : null;
    final to = CycleStatus.fromWire(op.payload['to'] as String);
    final row = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingleOrNull();
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
    if (!LwwRegister.shouldApply(
      incomingHlc: _decodeHlc(op.hlc),
      incomingDeviceId: op.originDeviceId,
      existingHlcBytes: row.statusHlc,
      existingDeviceId: row.statusDeviceId,
    )) {
      return false;
    }
    await (_db.update(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(
      CyclesSyncCompanion(
        status: Value(to.wireValue),
        statusHlc: Value(_decodeHlcBytes(op.hlc)),
        statusDeviceId: Value(op.originDeviceId),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyCycleGuardianUpdate(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final row = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingleOrNull();
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
    await (_db.update(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(
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

  Future<bool> _applyCycleSignoffSet(SyncOperation op) async {
    final cycleId = op.payload['cycle_id'] as String;
    final memberId = op.payload['member_id'] as String;
    final row = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingleOrNull();
    if (row == null) {
      return false;
    }
    final signoffs =
        Map<String, dynamic>.from(jsonDecode(row.ceremonySignoffs) as Map);
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
    await (_db.update(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(
      CyclesSyncCompanion(
        ceremonySignoffs: Value(jsonEncode(signoffs)),
        updatedAtHlc: Value(_decodeHlcBytes(op.hlc)),
      ),
    );
    return true;
  }

  Future<bool> _applyTaskCreate(SyncOperation op) async {
    final taskId = op.payload['task_id'] as String;
    final existing = await (_db.select(_db.tasksSync)
          ..where((t) => t.taskId.equals(taskId)))
        .getSingleOrNull();
    if (existing != null) {
      return false;
    }
    await _db.into(_db.tasksSync).insert(
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
    List<MergeSideEffect> sideEffects,
  ) async {
    final taskId = op.payload['task_id'] as String;
    final row = await (_db.select(_db.tasksSync)
          ..where((t) => t.taskId.equals(taskId)))
        .getSingleOrNull();
    if (row == null) {
      return false;
    }
    final field = op.payload['field'] as String;
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
        if (!LwwRegister.shouldApply(
          incomingHlc: incomingHlc,
          incomingDeviceId: op.originDeviceId,
          existingHlcBytes: row.statusHlc,
          existingDeviceId: row.statusDeviceId,
        )) {
          return false;
        }
        updateCompanion = TasksSyncCompanion(
          status: Value(op.payload['value'] as String),
          statusHlc: Value(hlcBytes),
          statusDeviceId: Value(op.originDeviceId),
          updatedAtHlc: Value(hlcBytes),
        );
      default:
        return false;
    }
    await (_db.update(_db.tasksSync)..where((t) => t.taskId.equals(taskId)))
        .write(updateCompanion);
    return true;
  }

  Future<bool> _applyTaskClaim(SyncOperation op) async {
    final eventId = op.payload['event_id'] as String;
    final inserted = await _db.into(_db.taskClaimEvents).insert(
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
    final events = await (_db.select(_db.taskClaimEvents)
          ..where((t) => t.taskId.equals(taskId)))
        .get();
    final memberIds = events.map((e) => e.memberId).toSet().toList();
    await (_db.update(_db.tasksSync)..where((t) => t.taskId.equals(taskId)))
        .write(
      TasksSyncCompanion(
        claimedByMemberIds: Value(jsonEncode(memberIds)),
      ),
    );
  }

  Future<bool> _applyAuditLogAppend(SyncOperation op) async {
    final logId = op.payload['log_id'] as String;
    final inserted = await _db.into(_db.auditLogAppendOnly).insert(
          AuditLogAppendOnlyCompanion.insert(
            logId: logId,
            houseId: op.houseId,
            taskId: op.payload['task_id'] as String,
            actorMemberId: op.payload['actor_member_id'] as String,
            action: op.payload['action'] as String,
            justificationNotes:
                Value(op.payload['justification_notes'] as String?),
            hlc: _decodeHlcBytes(op.hlc),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return inserted > 0;
  }

  String payloadString(SyncOperation op, String key) =>
      op.payload[key] as String;
}
