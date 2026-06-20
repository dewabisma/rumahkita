import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/entities/removal_proposal.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/removal_majority_evaluator.dart';
import 'package:rumah/sync/removal_op_ids.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

/// Emits follow-up removal ops when votes or proposal status change.
class RemovalMergeSideEffectHandler implements MergeSideEffectHandler {
  RemovalMergeSideEffectHandler(this._db);

  final AppDatabase _db;
  SyncWriteCoordinator? _sync;
  final _uuid = const Uuid();

  void bindSync(SyncWriteCoordinator sync) => _sync = sync;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      if (effect is ProposalCreated) {
        await _handleProposalCreated(effect);
      } else if (effect is VoteCastApplied) {
        await _handleVoteCastApplied(effect);
      } else if (effect is ProposalStatusChanged) {
        await _handleProposalStatusChanged(effect);
      }
    }
  }

  Future<void> _handleProposalCreated(ProposalCreated effect) async {
    final actor = effect.proposerMemberId ?? effect.targetMemberId;
    await emitAudit(
      houseId: effect.houseId,
      proposalId: effect.proposalId,
      actorMemberId: actor,
      action: 'removal_proposal_created',
      justificationNotes: effect.justificationNotes,
      auditOpId: removalProposalCreatedAuditOpId(effect.proposalId),
    );
  }

  Future<void> _handleVoteCastApplied(VoteCastApplied effect) async {
    final sync = _sync;
    if (sync == null) {
      return;
    }
    final proposal = await (_db.select(_db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(effect.proposalId)))
        .getSingleOrNull();
    if (proposal == null) {
      return;
    }
    final status = ProposalStatus.fromWire(proposal.status);
    if (status != ProposalStatus.proposed) {
      return;
    }

    final snapshot = await _majoritySnapshot(
      houseId: effect.houseId,
      proposalId: effect.proposalId,
      targetMemberId: proposal.targetMemberId,
      statusWire: proposal.status,
    );

    final ops = <SyncOperation>[];
    if (snapshot.thresholdMet) {
      if (!await _isOpApplied(removalApprovedOpId(effect.proposalId))) {
        ops.add(
          sync.opFactory.proposalStatusTransition(
            opId: removalApprovedOpId(effect.proposalId),
            houseId: effect.houseId,
            proposalId: effect.proposalId,
            from: ProposalStatus.proposed,
            to: ProposalStatus.approved,
          ),
        );
      }
    } else if (snapshot.impossibleToReach) {
      if (!await _isOpApplied(removalRejectedOpId(effect.proposalId))) {
        ops.add(
          sync.opFactory.proposalStatusTransition(
            opId: removalRejectedOpId(effect.proposalId),
            houseId: effect.houseId,
            proposalId: effect.proposalId,
            from: ProposalStatus.proposed,
            to: ProposalStatus.rejected,
          ),
        );
      }
    }

    if (ops.isNotEmpty) {
      await _emitLocalOps(effect.houseId, ops);
    }

    await emitAudit(
      houseId: effect.houseId,
      proposalId: effect.proposalId,
      actorMemberId: effect.voterMemberId,
      action: effect.voteCast ? 'removal_vote_yes' : 'removal_vote_no',
      auditOpId: removalVoteCastAuditOpId(
        effect.proposalId,
        effect.voterMemberId,
      ),
    );
  }

  Future<void> _handleProposalStatusChanged(
    ProposalStatusChanged effect,
  ) async {
    final sync = _sync;
    if (sync == null) {
      return;
    }
    final to = ProposalStatus.fromWire(effect.to);

    switch (to) {
      case ProposalStatus.approved:
        await emitAudit(
          houseId: effect.houseId,
          proposalId: effect.proposalId,
          actorMemberId: effect.targetMemberId,
          action: 'removal_proposal_approved',
          auditOpId: removalStatusAuditOpId(effect.proposalId, effect.to),
        );
        if (await _isOpApplied(removalReadyOpId(effect.proposalId))) {
          return;
        }
        await _emitLocalOps(effect.houseId, [
          sync.opFactory.proposalStatusTransition(
            opId: removalReadyOpId(effect.proposalId),
            houseId: effect.houseId,
            proposalId: effect.proposalId,
            from: ProposalStatus.approved,
            to: ProposalStatus.readyToExecute,
          ),
        ]);
      case ProposalStatus.rejected:
        await emitAudit(
          houseId: effect.houseId,
          proposalId: effect.proposalId,
          actorMemberId: effect.targetMemberId,
          action: 'removal_proposal_rejected',
          auditOpId: removalStatusAuditOpId(effect.proposalId, effect.to),
        );
      case ProposalStatus.readyToExecute:
        await emitAudit(
          houseId: effect.houseId,
          proposalId: effect.proposalId,
          actorMemberId: effect.targetMemberId,
          action: 'removal_ready_to_execute',
          auditOpId: removalStatusAuditOpId(effect.proposalId, effect.to),
        );
      default:
        break;
    }
  }

  Future<RemovalMajoritySnapshot> _majoritySnapshot({
    required String houseId,
    required String proposalId,
    required String targetMemberId,
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

  Future<bool> _isOpApplied(String opId) async {
    final row = await (_db.select(_db.syncAppliedOps)
          ..where((t) => t.opId.equals(opId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> _emitLocalOps(String houseId, List<SyncOperation> ops) async {
    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    await _sync!.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: null,
      ops: ops,
    );
  }

  Future<void> emitAudit({
    required String houseId,
    required String proposalId,
    required String actorMemberId,
    required String action,
    required String auditOpId,
    String? justificationNotes,
  }) async {
    final sync = _sync;
    if (sync == null) {
      return;
    }
    if (await _isOpApplied(auditOpId)) {
      return;
    }
    final logId = _uuid.v4();
    final ops = [
      sync.opFactory.auditLogAppend(
        opId: auditOpId,
        houseId: houseId,
        logId: logId,
        taskId: proposalId,
        actorMemberId: actorMemberId,
        action: action,
        justificationNotes: justificationNotes,
      ),
    ];
    await _emitLocalOps(houseId, ops);
  }
}
