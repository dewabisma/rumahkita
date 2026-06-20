import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/task_score_ids.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('approval emits deterministic split score events', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const guardian = 'guardian';
    const claimer = 'claimer';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardian,
    );
    await harness.seedHousemate(houseId: houseId, memberId: guardian);
    await harness.seedHousemate(houseId: houseId, memberId: claimer);
    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
      points: 10,
      claimedByMemberIds: [claimer],
    );

    await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: guardian,
        from: TaskStatus.pendingReview,
        to: TaskStatus.approved,
      ),
      houseId,
    );

    final expectedEventId = taskApproveScoreEventId(
      houseId: houseId,
      memberId: claimer,
      taskId: taskId,
    );
    final events = await (harness.db.select(
      harness.db.scoreEvents,
    )..where((t) => t.reasonRef.equals(taskApproveReasonRef(taskId)))).get();
    expect(events.length, 1);
    expect(events.single.eventId, expectedEventId);
    expect(events.single.delta, 10);
    expect(events.single.memberId, claimer);
  });

  test('splitTaskPoints distributes remainder to sorted claimants', () {
    final splits = splitTaskPoints(base: 10, claimantIds: ['b', 'a', 'c']);
    expect(splits['a'], 4);
    expect(splits['b'], 3);
    expect(splits['c'], 3);
    expect(splits.values.fold<int>(0, (a, b) => a + b), 10);
  });
}
