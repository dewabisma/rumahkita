import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('duplicate claim events are idempotent', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final eventId = uuid.v4();
    final memberId = uuid.v4();

    await harness.db.into(harness.db.tasksSync).insert(
          TasksSyncCompanion.insert(
            taskId: taskId,
            houseId: houseId,
            cycleId: uuid.v4(),
            title: 'Trash',
            negotiatedPoints: 10,
            status: 'open',
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final op = harness.taskClaim(
      opId: uuid.v4(),
      houseId: houseId,
      eventId: eventId,
      taskId: taskId,
      memberId: memberId,
    );
    await harness.apply(op, houseId);
    await harness.apply(
      SyncOperation(
        opId: uuid.v4(),
        opType: SyncOpType.taskClaim.wireValue,
        houseId: houseId,
        originDeviceId: harness.deviceId,
        hlc: op.hlc,
        payload: op.payload,
      ),
      houseId,
    );

    final events = await (harness.db.select(harness.db.taskClaimEvents)
          ..where((t) => t.taskId.equals(taskId)))
        .get();
    expect(events.length, 1);
  });

  test('set union converges across peers', () async {
    final peerA = await SyncTestHarness.create(deviceId: 'a', nodeKey: 'node-a');
    final peerB = await SyncTestHarness.create(deviceId: 'b', nodeKey: 'node-b');
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();

    for (final harness in [peerA, peerB]) {
      await harness.db.into(harness.db.tasksSync).insert(
            TasksSyncCompanion.insert(
              taskId: taskId,
              houseId: houseId,
              cycleId: cycleId,
              title: 'Dishes',
              negotiatedPoints: 15,
              status: 'open',
              updatedAtHlc:
                  harness.hlcService.toBytes(harness.hlcService.now()),
            ),
          );
    }

    await peerA.apply(
      peerA.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        taskId: taskId,
        memberId: 'member-1',
      ),
      houseId,
    );
    await peerB.apply(
      peerB.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        taskId: taskId,
        memberId: 'member-2',
      ),
      houseId,
    );

    final claimA = await (peerA.db.select(peerA.db.taskClaimEvents)
          ..where((t) => t.taskId.equals(taskId)))
        .get();
    await peerB.apply(
      peerB.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: claimA.single.eventId,
        taskId: taskId,
        memberId: claimA.single.memberId,
      ),
      houseId,
    );

    final taskB = await (peerB.db.select(peerB.db.tasksSync)
          ..where((t) => t.taskId.equals(taskId)))
        .getSingle();
    expect(taskB.claimedByMemberIds, contains('member-1'));
    expect(taskB.claimedByMemberIds, contains('member-2'));
  });
}
