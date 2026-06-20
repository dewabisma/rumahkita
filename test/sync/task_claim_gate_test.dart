import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('claim rejected when task is not open', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const memberId = 'member-1';

    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);

    final result = await harness.apply(
      harness.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        taskId: taskId,
        memberId: memberId,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('claim rejected when claim events already exist', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.seedTask(houseId: houseId, taskId: taskId, cycleId: cycleId);
    await harness.seedHousemate(houseId: houseId, memberId: 'member-1');

    await harness.db
        .into(harness.db.taskClaimEvents)
        .insert(
          TaskClaimEventsCompanion.insert(
            eventId: uuid.v4(),
            houseId: houseId,
            taskId: taskId,
            memberId: 'member-1',
            hlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final result = await harness.apply(
      harness.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        taskId: taskId,
        memberId: 'member-2',
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });
}
