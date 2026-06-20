import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/sync/ceremony_guardian.dart';

void main() {
  group('resolveGuardianForActivation', () {
    test('first cycle uses deterministic guardian', () {
      const cycleId = 'cycle-1';
      final memberIds = ['member-b', 'member-a', 'member-c'];

      final guardian = resolveGuardianForActivation(
        cycleId: cycleId,
        activeMemberIds: memberIds,
        activeRotationRoster: const [
          RotationRosterMember(memberId: 'member-a', rotationOrderIndex: 0),
          RotationRosterMember(memberId: 'member-b', rotationOrderIndex: 1),
        ],
        previousCycleGuardianId: null,
        previousGuardianRotationIndex: null,
      );

      expect(guardian, pickDeterministicGuardian(cycleId, memberIds));
    });
  });

  group('pickNextGuardian', () {
    const roster = [
      RotationRosterMember(memberId: 'a', rotationOrderIndex: 0),
      RotationRosterMember(memberId: 'b', rotationOrderIndex: 1),
      RotationRosterMember(memberId: 'c', rotationOrderIndex: 2),
    ];

    test('wraps around A to B to C to A', () {
      expect(
        pickNextGuardian(
          previousGuardianId: 'a',
          activeRoster: roster,
          previousGuardianRotationIndex: 0,
        ),
        'b',
      );
      expect(
        pickNextGuardian(
          previousGuardianId: 'b',
          activeRoster: roster,
          previousGuardianRotationIndex: 1,
        ),
        'c',
      );
      expect(
        pickNextGuardian(
          previousGuardianId: 'c',
          activeRoster: roster,
          previousGuardianRotationIndex: 2,
        ),
        'a',
      );
    });

    test('skips inactive members via active-only roster', () {
      final activeOnly = [
        const RotationRosterMember(memberId: 'a', rotationOrderIndex: 0),
        const RotationRosterMember(memberId: 'c', rotationOrderIndex: 2),
      ];

      expect(
        pickNextGuardian(
          previousGuardianId: 'a',
          activeRoster: activeOnly,
          previousGuardianRotationIndex: 0,
        ),
        'c',
      );
      expect(
        pickNextGuardian(
          previousGuardianId: 'c',
          activeRoster: activeOnly,
          previousGuardianRotationIndex: 2,
        ),
        'a',
      );
    });

    test('empty roster throws', () {
      expect(
        () => pickNextGuardian(
          previousGuardianId: 'a',
          activeRoster: const [],
          previousGuardianRotationIndex: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
