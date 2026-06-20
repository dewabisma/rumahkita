import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/entities/removal_proposal.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:rumah/domain/repositories/removal_repository.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/removal_majority_evaluator.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

class DriftRemovalRepository implements RemovalRepository {
  DriftRemovalRepository({
    required AppDatabase db,
    required SyncWriteCoordinator sync,
    Uuid? uuid,
  })  : _db = db,
        _sync = sync,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncWriteCoordinator _sync;
  final Uuid _uuid;

  static const _nonTerminalStatuses = [
    'proposed',
    'approved',
    'ready_to_execute',
  ];

  @override
  Stream<List<RemovalProposal>> watchProposals(String houseId) {
    final query = _db.select(_db.removalProposalsSync)
      ..where((t) => t.houseId.equals(houseId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAtHlc)]);
    return query.watch().map((rows) => rows.map(_toProposal).toList());
  }

  @override
  Stream<RemovalProposal?> watchProposal(String proposalId) {
    final query = _db.select(_db.removalProposalsSync)
      ..where((t) => t.proposalId.equals(proposalId));
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return _toProposal(rows.first);
    });
  }

  @override
  Stream<List<ProposalVote>> watchVotes(String proposalId) {
    final query = _db.select(_db.proposalVotesSync)
      ..where((t) => t.proposalId.equals(proposalId));
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ProposalVote(
              voteId: row.voteId,
              houseId: row.houseId,
              proposalId: row.proposalId,
              voterMemberId: row.voterMemberId,
              voteCast: row.voteCast == 1,
              hlc: row.hlc,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<RemovalMajoritySnapshot> majoritySnapshot(String proposalId) async {
    final proposal = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingleOrNull();
    if (proposal == null) {
      throw StateError('Proposal not found');
    }
    return _computeMajority(
      houseId: proposal.houseId,
      targetMemberId: proposal.targetMemberId,
      proposalId: proposalId,
      statusWire: proposal.status,
    );
  }

  @override
  Future<RemovalProposal> proposeEviction({
    required String houseId,
    required String proposerMemberId,
    required String targetMemberId,
    String? justificationNotes,
  }) async {
    await _guardActiveMember(houseId, proposerMemberId);
    await _guardActiveMember(houseId, targetMemberId);
    await _guardNoConflictingProposal(houseId, targetMemberId);
    await _guardNotGuardian(houseId, targetMemberId);

    final proposalId = _uuid.v4();
    final votingEnds = base64Encode(
      HandoverCycleHelpers.computeEndsAtHlc(
        startedAtHlc: _sync.hlcService.toBytes(_sync.hlcService.now()),
        cycleDurationDays: 7,
      ),
    );
    final createOp = _sync.opFactory.proposalCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      proposalId: proposalId,
      targetMemberId: targetMemberId,
      proposerMemberId: proposerMemberId,
      type: ProposalType.eviction,
      votingWindowEndsAtHlc: votingEnds,
      justificationNotes: justificationNotes,
    );

    await _emit(
      houseId: houseId,
      senderMemberId: proposerMemberId,
      ops: [createOp],
    );

    final row = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    return _toProposal(row);
  }

  @override
  Future<RemovalProposal> initiateSelfRemoval({
    required String houseId,
    required String targetMemberId,
  }) async {
    await _guardActiveMember(houseId, targetMemberId);
    await _guardNoConflictingProposal(houseId, targetMemberId);

    final proposalId = _uuid.v4();
    final ops = [
      _sync.opFactory.proposalCreate(
        opId: _uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: targetMemberId,
        type: ProposalType.selfRemoval,
      ),
      _sync.opFactory.proposalStatusTransition(
        opId: _uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        from: ProposalStatus.proposed,
        to: ProposalStatus.readyToExecute,
      ),
    ];

    await _emit(houseId: houseId, senderMemberId: targetMemberId, ops: ops);

    final row = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    return _toProposal(row);
  }

  @override
  Future<void> castVote({
    required String houseId,
    required String proposalId,
    required String voterMemberId,
    required bool voteYes,
  }) async {
    await _guardActiveMember(houseId, voterMemberId);
    final proposal = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingleOrNull();
    if (proposal == null) {
      throw StateError('Proposal not found');
    }
    if (proposal.targetMemberId == voterMemberId) {
      throw StateError('Target cannot vote on own removal');
    }
    if (proposal.status != ProposalStatus.proposed.wireValue) {
      throw StateError('Voting is closed for this proposal');
    }

    final op = _sync.opFactory.voteCast(
      opId: _uuid.v4(),
      houseId: houseId,
      voteId: _uuid.v4(),
      proposalId: proposalId,
      voterMemberId: voterMemberId,
      voteCast: voteYes,
    );
    await _emit(houseId: houseId, senderMemberId: voterMemberId, ops: [op]);
  }

  @override
  Future<void> cancelProposal({
    required String houseId,
    required String proposalId,
    required String actorMemberId,
  }) async {
    final proposal = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingleOrNull();
    if (proposal == null) {
      throw StateError('Proposal not found');
    }
    if (proposal.status != ProposalStatus.proposed.wireValue) {
      throw StateError('Only proposed removals can be cancelled');
    }
    final isProposer = proposal.proposerMemberId == actorMemberId;
    final isTarget = proposal.targetMemberId == actorMemberId;
    if (!isProposer && !isTarget) {
      throw StateError('Only proposer or target can cancel');
    }

    final op = _sync.opFactory.proposalStatusTransition(
      opId: _uuid.v4(),
      houseId: houseId,
      proposalId: proposalId,
      from: ProposalStatus.proposed,
      to: ProposalStatus.cancelled,
    );
    await _emit(houseId: houseId, senderMemberId: actorMemberId, ops: [op]);
  }

  Future<void> _guardActiveMember(String houseId, String memberId) async {
    final row = await (_db.select(_db.housematesSync)
          ..where(
            (t) => t.houseId.equals(houseId) & t.memberId.equals(memberId),
          ))
        .getSingleOrNull();
    if (row == null || row.memberStatus != MemberStatus.active.wireValue) {
      throw StateError('Member must be active');
    }
  }

  Future<void> _guardNoConflictingProposal(
    String houseId,
    String targetMemberId,
  ) async {
    final existing = await (_db.select(_db.removalProposalsSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.targetMemberId.equals(targetMemberId) &
                t.status.isIn(_nonTerminalStatuses),
          ))
        .getSingleOrNull();
    if (existing != null) {
      throw RemovalProposalConflictException(targetMemberId);
    }
  }

  Future<void> _guardNotGuardian(String houseId, String targetMemberId) async {
    final liveCycles = await (_db.select(_db.cyclesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.status.isIn([
                  CycleStatus.active.wireValue,
                  CycleStatus.handover.wireValue,
                ]),
          ))
        .get();
    final isGuardian = liveCycles.any(
      (c) => c.activeGuardianMemberId == targetMemberId,
    );
    if (isGuardian) {
      throw GuardianEvictionBlockedException(targetMemberId);
    }
  }

  Future<RemovalMajoritySnapshot> _computeMajority({
    required String houseId,
    required String targetMemberId,
    required String proposalId,
    required String statusWire,
  }) async {
    final activeCount = await (_db.select(_db.housematesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.memberStatus.equals(MemberStatus.active.wireValue),
          ))
        .get()
        .then((rows) => rows.length);
    final votes = await (_db.select(_db.proposalVotesSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .get();
    return RemovalMajorityEvaluator.evaluate(
      activeMemberCount: activeCount,
      targetMemberId: targetMemberId,
      votes: votes
          .map(
            (v) => (
              voterMemberId: v.voterMemberId,
              voteCast: v.voteCast == 1,
            ),
          )
          .toList(),
      proposalStatusWire: statusWire,
    );
  }

  RemovalProposal _toProposal(RemovalProposalsSyncData row) {
    return RemovalProposal(
      proposalId: row.proposalId,
      houseId: row.houseId,
      targetMemberId: row.targetMemberId,
      proposerMemberId: row.proposerMemberId,
      type: ProposalType.fromWire(row.type),
      status: ProposalStatus.fromWire(row.status),
      createdAtHlc: row.createdAtHlc,
      updatedAtHlc: row.updatedAtHlc,
      votingWindowEndsAtHlc: row.votingWindowEndsAtHlc,
    );
  }

  Future<void> _emit({
    required String houseId,
    required String? senderMemberId,
    required List<SyncOperation> ops,
  }) async {
    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: senderMemberId,
      ops: ops,
    );
  }
}
