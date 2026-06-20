import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('submit requires claimant actor', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const claimant = 'member-claim';
    const outsider = 'member-other';

    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      claimedByMemberIds: [claimant],
    );
    await harness.seedHousemate(houseId: houseId, memberId: claimant);
    await harness.seedHousemate(houseId: houseId, memberId: outsider);

    final result = await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: outsider,
        from: TaskStatus.open,
        to: TaskStatus.pendingReview,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('approve and reject require guardian actor', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const guardian = 'guardian';
    const other = 'other';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardian,
    );
    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
      claimedByMemberIds: ['claimer'],
    );
    await harness.seedHousemate(houseId: houseId, memberId: guardian);
    await harness.seedHousemate(houseId: houseId, memberId: other);

    final rejectFail = await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: other,
        from: TaskStatus.pendingReview,
        to: TaskStatus.open,
      ),
      houseId,
    );
    expect(rejectFail.rejectedOpIds.length, 1);

    final rejectOk = await harness.apply(
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
    expect(rejectOk.appliedOpIds.length, 1);

    await (harness.db.update(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).write(
      TasksSyncCompanion(status: Value(TaskStatus.pendingReview.wireValue)),
    );

    final approveOk = await harness.apply(
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
    expect(approveOk.appliedOpIds.length, 1);
  });

  test('approve and reject rejected when guardian is inactive', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const guardian = 'guardian';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardian,
    );
    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
      claimedByMemberIds: ['claimer'],
    );
    await harness.seedHousemate(
      houseId: houseId,
      memberId: guardian,
      status: MemberStatus.evicted,
    );

    final rejectFail = await harness.apply(
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
    expect(rejectFail.rejectedOpIds.length, 1);

    final approveFail = await harness.apply(
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
    expect(approveFail.rejectedOpIds.length, 1);
  });
}
