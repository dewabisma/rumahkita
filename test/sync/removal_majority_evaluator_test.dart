import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/sync/removal_majority_evaluator.dart';

void main() {
  group('RemovalMajorityEvaluator.requiredYesVotes', () {
    test('2 members: target excluded → 1 eligible → need 1 yes', () {
      expect(RemovalMajorityEvaluator.requiredYesVotes(1), 1);
    });

    test('3 members: 2 eligible → need 2 yes', () {
      expect(RemovalMajorityEvaluator.requiredYesVotes(2), 2);
    });

    test('4 members: 3 eligible → need 2 yes', () {
      expect(RemovalMajorityEvaluator.requiredYesVotes(3), 2);
    });

    test('5 members: 4 eligible → need 3 yes', () {
      expect(RemovalMajorityEvaluator.requiredYesVotes(4), 3);
    });
  });

  group('RemovalMajorityEvaluator.evaluate', () {
    const target = 'member-b';

    test('threshold met with minimum yes votes', () {
      final snapshot = RemovalMajorityEvaluator.evaluate(
        activeMemberCount: 2,
        targetMemberId: target,
        votes: const [(voterMemberId: 'member-a', voteCast: true)],
        proposalStatusWire: 'proposed',
      );
      expect(snapshot.eligibleVoters, 1);
      expect(snapshot.requiredYes, 1);
      expect(snapshot.yesCount, 1);
      expect(snapshot.thresholdMet, isTrue);
      expect(snapshot.impossibleToReach, isFalse);
    });

    test('target vote is excluded from tally', () {
      final snapshot = RemovalMajorityEvaluator.evaluate(
        activeMemberCount: 2,
        targetMemberId: target,
        votes: const [(voterMemberId: target, voteCast: true)],
        proposalStatusWire: 'proposed',
      );
      expect(snapshot.yesCount, 0);
      expect(snapshot.thresholdMet, isFalse);
    });

    test('impossible when remaining voters cannot reach threshold', () {
      final snapshot = RemovalMajorityEvaluator.evaluate(
        activeMemberCount: 3,
        targetMemberId: target,
        votes: const [
          (voterMemberId: 'member-a', voteCast: false),
          (voterMemberId: 'member-c', voteCast: false),
        ],
        proposalStatusWire: 'proposed',
      );
      expect(snapshot.requiredYes, 2);
      expect(snapshot.yesCount, 0);
      expect(snapshot.impossibleToReach, isTrue);
    });
  });
}
