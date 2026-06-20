import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:uuid/uuid.dart';

import '../sync/sync_test_harness.dart';

void main() {
  test('full claim submit approve loop', () async {
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
      points: 15,
    );

    final repo = DriftTaskRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
      uuid: uuid,
    );

    await repo.claim(houseId: houseId, taskId: taskId, actorMemberId: claimer);

    var task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.claimedByMemberIds, contains(claimer));
    expect(task.status, TaskStatus.open.wireValue);

    await repo.submitForReview(
      houseId: houseId,
      taskId: taskId,
      actorMemberId: claimer,
    );

    task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.pendingReview.wireValue);

    await repo.approve(
      houseId: houseId,
      taskId: taskId,
      guardianMemberId: guardian,
    );

    task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.approved.wireValue);

    final scores = await (harness.db.select(
      harness.db.scoreEvents,
    )..where((t) => t.memberId.equals(claimer))).get();
    expect(scores.any((e) => e.delta == 15), isTrue);
  });

  test('reject and resubmit loop', () async {
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
    await harness.seedTask(houseId: houseId, taskId: taskId, cycleId: cycleId);

    final repo = DriftTaskRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
      uuid: uuid,
    );

    await repo.claim(houseId: houseId, taskId: taskId, actorMemberId: claimer);
    await repo.submitForReview(
      houseId: houseId,
      taskId: taskId,
      actorMemberId: claimer,
    );
    await repo.reject(
      houseId: houseId,
      taskId: taskId,
      guardianMemberId: guardian,
      justificationNotes: 'Needs more love',
    );

    var task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.open.wireValue);

    await repo.submitForReview(
      houseId: houseId,
      taskId: taskId,
      actorMemberId: claimer,
    );

    task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.pendingReview.wireValue);

    final audit = await (harness.db.select(
      harness.db.auditLogAppendOnly,
    )..where((t) => t.taskId.equals(taskId))).get();
    expect(audit.any((e) => e.action == 'reject'), isTrue);
    expect(audit.any((e) => e.action == 'submit_for_review'), isTrue);
  });

  test('non-guardian cannot approve', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const guardian = 'guardian';
    const claimer = 'claimer';
    const other = 'other';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardian,
    );
    await harness.seedHousemate(houseId: houseId, memberId: guardian);
    await harness.seedHousemate(houseId: houseId, memberId: claimer);
    await harness.seedHousemate(houseId: houseId, memberId: other);
    await harness.seedTask(houseId: houseId, taskId: taskId, cycleId: cycleId);

    final repo = DriftTaskRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
      uuid: uuid,
    );

    await repo.claim(houseId: houseId, taskId: taskId, actorMemberId: claimer);
    await repo.submitForReview(
      houseId: houseId,
      taskId: taskId,
      actorMemberId: claimer,
    );

    expect(
      () => repo.approve(
        houseId: houseId,
        taskId: taskId,
        guardianMemberId: other,
      ),
      throwsA(isA<TaskOperationException>()),
    );

    final task = await (harness.db.select(
      harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.pendingReview.wireValue);
  });
}
