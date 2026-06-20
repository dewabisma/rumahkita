import 'package:rumah/domain/entities/removal_proposal.dart';

/// Pure vote-threshold math for removal proposals.
class RemovalMajorityEvaluator {
  RemovalMajorityEvaluator._();

  static const Set<String> _terminalStatuses = {
    'executed',
    'cancelled',
    'rejected',
  };

  /// Strict majority of eligible voters (active members excluding target).
  static int requiredYesVotes(int eligibleVoters) =>
      (eligibleVoters / 2).floor() + 1;

  static RemovalMajoritySnapshot evaluate({
    required int activeMemberCount,
    required String targetMemberId,
    required Iterable<({String voterMemberId, bool voteCast})> votes,
    String? proposalStatusWire,
  }) {
    final eligibleVoters = activeMemberCount > 0 ? activeMemberCount - 1 : 0;
    final requiredYes = requiredYesVotes(eligibleVoters);

    var yesCount = 0;
    var noCount = 0;
    final voted = <String>{};
    for (final vote in votes) {
      if (vote.voterMemberId == targetMemberId) {
        continue;
      }
      voted.add(vote.voterMemberId);
      if (vote.voteCast) {
        yesCount++;
      } else {
        noCount++;
      }
    }

    final thresholdMet = yesCount >= requiredYes;
    final remainingUndecided = eligibleVoters - voted.length;
    final maxPossibleYes = yesCount + remainingUndecided;
    final isTerminal =
        proposalStatusWire != null &&
        _terminalStatuses.contains(proposalStatusWire);
    final impossibleToReach =
        !isTerminal && maxPossibleYes < requiredYes;

    return RemovalMajoritySnapshot(
      eligibleVoters: eligibleVoters,
      requiredYes: requiredYes,
      yesCount: yesCount,
      noCount: noCount,
      thresholdMet: thresholdMet,
      impossibleToReach: impossibleToReach,
    );
  }
}
