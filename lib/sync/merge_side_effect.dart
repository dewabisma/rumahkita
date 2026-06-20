sealed class MergeSideEffect {
  const MergeSideEffect();
}

class RulesVersionBumped extends MergeSideEffect {
  const RulesVersionBumped({
    required this.houseId,
    required this.oldVersion,
    required this.newVersion,
    required this.hlc,
  });

  final String houseId;
  final int oldVersion;
  final int newVersion;
  final List<int> hlc;
}

class TaskPointsChanged extends MergeSideEffect {
  const TaskPointsChanged({
    required this.taskId,
    required this.cycleId,
    required this.oldPoints,
    required this.newPoints,
    required this.hlc,
  });

  final String taskId;
  final String cycleId;
  final int oldPoints;
  final int newPoints;
  final List<int> hlc;
}

class CeremonySignoffsChanged extends MergeSideEffect {
  const CeremonySignoffsChanged({required this.houseId, required this.cycleId});

  final String houseId;
  final String cycleId;
}

class HandoverStarted extends MergeSideEffect {
  const HandoverStarted({
    required this.houseId,
    required this.cycleId,
    required this.guardianMemberId,
    required this.hlc,
  });

  final String houseId;
  final String cycleId;
  final String guardianMemberId;
  final List<int> hlc;
}

class TaskApproved extends MergeSideEffect {
  const TaskApproved({
    required this.houseId,
    required this.taskId,
    required this.cycleId,
    required this.negotiatedPoints,
    required this.claimedByMemberIds,
    required this.hlc,
  });

  final String houseId;
  final String taskId;
  final String cycleId;
  final int negotiatedPoints;
  final List<String> claimedByMemberIds;
  final List<int> hlc;
}

class ScoreChanged extends MergeSideEffect {
  const ScoreChanged({
    required this.houseId,
    required this.memberId,
    required this.oldScore,
    required this.newScore,
    required this.triggeringEventId,
    required this.hlc,
  });

  final String houseId;
  final String memberId;
  final int oldScore;
  final int newScore;
  final String triggeringEventId;
  final List<int> hlc;
}

class ProposalCreated extends MergeSideEffect {
  const ProposalCreated({
    required this.houseId,
    required this.proposalId,
    required this.targetMemberId,
    this.proposerMemberId,
    required this.type,
    this.justificationNotes,
    required this.hlc,
  });

  final String houseId;
  final String proposalId;
  final String targetMemberId;
  final String? proposerMemberId;
  final String type;
  final String? justificationNotes;
  final List<int> hlc;
}

class VoteCastApplied extends MergeSideEffect {
  const VoteCastApplied({
    required this.houseId,
    required this.proposalId,
    required this.voterMemberId,
    required this.voteCast,
    required this.hlc,
  });

  final String houseId;
  final String proposalId;
  final String voterMemberId;
  final bool voteCast;
  final List<int> hlc;
}

class ProposalStatusChanged extends MergeSideEffect {
  const ProposalStatusChanged({
    required this.houseId,
    required this.proposalId,
    required this.from,
    required this.to,
    required this.targetMemberId,
    required this.type,
    required this.hlc,
  });

  final String houseId;
  final String proposalId;
  final String? from;
  final String to;
  final String targetMemberId;
  final String type;
  final List<int> hlc;
}

class RemovalReadyToExecute extends MergeSideEffect {
  const RemovalReadyToExecute({
    required this.houseId,
    required this.proposalId,
    required this.targetMemberId,
    required this.targetNodeKey,
    required this.hlc,
  });

  final String houseId;
  final String proposalId;
  final String targetMemberId;
  final String targetNodeKey;
  final List<int> hlc;
}

abstract class MergeSideEffectHandler {
  Future<void> handle(List<MergeSideEffect> effects);
}

class NoOpMergeSideEffectHandler implements MergeSideEffectHandler {
  @override
  Future<void> handle(List<MergeSideEffect> effects) async {}
}

/// Delegates side effects to multiple handlers without merging their logic.
class CompositeMergeSideEffectHandler implements MergeSideEffectHandler {
  CompositeMergeSideEffectHandler(this._handlers);

  final List<MergeSideEffectHandler> _handlers;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final handler in _handlers) {
      await handler.handle(effects);
    }
  }
}

class MergeResult {
  const MergeResult({
    required this.appliedOpIds,
    required this.rejectedOpIds,
    required this.sideEffects,
    this.error,
  });

  final List<String> appliedOpIds;
  final List<String> rejectedOpIds;
  final List<MergeSideEffect> sideEffects;
  final String? error;

  bool get success {
    if (error != null) {
      return false;
    }
    if (appliedOpIds.isEmpty && rejectedOpIds.isNotEmpty) {
      return false;
    }
    return true;
  }
}
