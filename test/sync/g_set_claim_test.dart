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

    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: uuid.v4(),
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);

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

    final events = await (harness.db.select(
      harness.db.taskClaimEvents,
    )..where((t) => t.taskId.equals(taskId))).get();
    expect(events.length, 1);
  });

  test('second claim is rejected when task already claimed', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.seedTask(houseId: houseId, taskId: taskId, cycleId: cycleId);
    await harness.seedHousemate(houseId: houseId, memberId: 'member-1');
    await harness.seedHousemate(houseId: houseId, memberId: 'member-2');

    await harness.apply(
      harness.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        taskId: taskId,
        memberId: 'member-1',
      ),
      houseId,
    );

    final second = await harness.apply(
      harness.taskClaim(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        taskId: taskId,
        memberId: 'member-2',
      ),
      houseId,
    );
    expect(second.rejectedOpIds.length, 1);

    final events = await (harness.db.select(
      harness.db.taskClaimEvents,
    )..where((t) => t.taskId.equals(taskId))).get();
    expect(events.length, 1);
    expect(events.single.memberId, 'member-1');
  });
}
