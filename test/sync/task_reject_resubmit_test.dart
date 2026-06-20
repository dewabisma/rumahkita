import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('reject returns task to open without clearing claim g-set', () async {
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
      claimedByMemberIds: [claimer],
    );
    await harness.db
        .into(harness.db.taskClaimEvents)
        .insert(
          TaskClaimEventsCompanion.insert(
            eventId: uuid.v4(),
            houseId: houseId,
            taskId: taskId,
            memberId: claimer,
            hlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: guardian,
        from: TaskStatus.pendingReview,
        to: TaskStatus.open,
      ),
      houseId,
    );

    final task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.open.wireValue);
    expect(task.claimedByMemberIds, contains(claimer));

    final claims = await (harness.db.select(
      harness.db.taskClaimEvents,
    )..where((t) => t.taskId.equals(taskId))).get();
    expect(claims.length, 1);
  });

  test('resubmit moves open to pendingReview without new claim', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const claimer = 'claimer';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: 'guardian',
    );
    await harness.seedHousemate(houseId: houseId, memberId: claimer);
    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.open.wireValue,
      claimedByMemberIds: [claimer],
    );

    await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: claimer,
        from: TaskStatus.open,
        to: TaskStatus.pendingReview,
      ),
      houseId,
    );

    final task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.pendingReview.wireValue);

    final claims = await (harness.db.select(
      harness.db.taskClaimEvents,
    )..where((t) => t.taskId.equals(taskId))).get();
    expect(claims.length, 0);
  });
}
