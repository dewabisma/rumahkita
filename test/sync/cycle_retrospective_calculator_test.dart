import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/cycle_retrospective_calculator.dart';

void main() {
  test('computes mvp and neglected chores', () {
    final retro = calculateCycleRetrospective(
      cycleStartScoresJson: '{"a":10,"b":5}',
      currentScoresByMemberId: {'a': 25, 'b': 8},
      cycleTasks: const [
        Task(
          taskId: 't1',
          houseId: 'h',
          cycleId: 'c',
          title: 'Dishes',
          description: '',
          negotiatedPoints: 5,
          status: TaskStatus.approved,
          assignedToMemberId: 'a',
          claimedByMemberIds: ['a'],
          updatedAtHlc: [],
        ),
        Task(
          taskId: 't2',
          houseId: 'h',
          cycleId: 'c',
          title: 'Laundry',
          description: '',
          negotiatedPoints: 3,
          status: TaskStatus.open,
          assignedToMemberId: '',
          claimedByMemberIds: [],
          updatedAtHlc: [],
        ),
      ],
    );

    expect(retro.mvpMemberId, 'a');
    expect(retro.neglectedChoreTitles, ['Laundry']);
  });
}
