import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';

class RemovalProposal {
  const RemovalProposal({
    required this.proposalId,
    required this.houseId,
    required this.targetMemberId,
    this.proposerMemberId,
    required this.type,
    required this.status,
    required this.createdAtHlc,
    required this.updatedAtHlc,
    this.votingWindowEndsAtHlc,
  });

  final String proposalId;
  final String houseId;
  final String targetMemberId;
  final String? proposerMemberId;
  final ProposalType type;
  final ProposalStatus status;
  final List<int> createdAtHlc;
  final List<int> updatedAtHlc;
  final List<int>? votingWindowEndsAtHlc;
}

class ProposalVote {
  const ProposalVote({
    required this.voteId,
    required this.houseId,
    required this.proposalId,
    required this.voterMemberId,
    required this.voteCast,
    required this.hlc,
  });

  final String voteId;
  final String houseId;
  final String proposalId;
  final String voterMemberId;
  final bool voteCast;
  final List<int> hlc;
}

class RemovalMajoritySnapshot {
  const RemovalMajoritySnapshot({
    required this.eligibleVoters,
    required this.requiredYes,
    required this.yesCount,
    required this.noCount,
    required this.thresholdMet,
    required this.impossibleToReach,
  });

  final int eligibleVoters;
  final int requiredYes;
  final int yesCount;
  final int noCount;
  final bool thresholdMet;
  final bool impossibleToReach;
}
