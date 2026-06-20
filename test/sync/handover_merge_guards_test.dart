import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('blocks task create on handover cycle', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: uuid.v4(),
      status: 'handover',
    );

    final result = await harness.apply(
      harness.opFactory.taskCreate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: uuid.v4(),
        cycleId: cycleId,
        title: 'Late chore',
        negotiatedPoints: 5,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('blocks early active to handover before ends_at', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final started = harness.hlcService.toBytes(harness.hlcService.now());
    final ends = HandoverCycleHelpers.computeEndsAtHlc(
      startedAtHlc: started,
      cycleDurationDays: 7,
    );

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: uuid.v4(),
      status: 'active',
    );
    await (harness.db.update(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(
          CyclesSyncCompanion(
            startedAtHlc: Value(started),
            endsAtHlc: Value(ends),
          ),
        );

    final result = await harness.apply(
      harness.cycleStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        cycleId: cycleId,
        from: 'active',
        to: 'handover',
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('blocks retro advance while pending review remains', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final guardianId = uuid.v4();

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardianId,
      status: 'handover',
    );
    await (harness.db.update(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(const CyclesSyncCompanion(handoverStep: Value('closeout')));

    await harness.seedTask(
      houseId: houseId,
      taskId: uuid.v4(),
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
    );

    final result = await harness.apply(
      _handoverAdvance(
        harness: harness,
        houseId: houseId,
        cycleId: cycleId,
        actorMemberId: guardianId,
        from: HandoverStep.closeout.wireValue,
        to: HandoverStep.retro.wireValue,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('allows approve pendingReview on closeout, blocks on retro', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final taskId = uuid.v4();
    final guardianId = uuid.v4();

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardianId,
      status: 'handover',
    );
    await harness.seedHousemate(houseId: houseId, memberId: guardianId);
    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
      claimedByMemberIds: [uuid.v4()],
    );

    final closeoutApprove = await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: guardianId,
        from: TaskStatus.pendingReview,
        to: TaskStatus.approved,
      ),
      houseId,
    );
    expect(closeoutApprove.appliedOpIds.length, 1);

    await (harness.db.update(harness.db.tasksSync)
          ..where((t) => t.taskId.equals(taskId)))
        .write(TasksSyncCompanion(status: Value(TaskStatus.pendingReview.wireValue)));
    await (harness.db.update(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(const CyclesSyncCompanion(handoverStep: Value('retro')));

    final retroApprove = await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: guardianId,
        from: TaskStatus.pendingReview,
        to: TaskStatus.approved,
      ),
      houseId,
    );
    expect(retroApprove.rejectedOpIds.length, 1);
  });
}

SyncOperation _handoverAdvance({
  required SyncTestHarness harness,
  required String houseId,
  required String cycleId,
  required String actorMemberId,
  required String from,
  required String to,
}) {
  return SyncOperation(
    opId: const Uuid().v4(),
    opType: SyncOpType.cycleHandoverStepAdvance.wireValue,
    houseId: houseId,
    originDeviceId: harness.deviceId,
    actorMemberId: actorMemberId,
    hlc: base64Encode(harness.hlcService.toBytes(harness.hlcService.now())),
    payload: {'cycle_id': cycleId, 'from': from, 'to': to},
  );
}
