import 'package:rumah/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('same op_id applied twice has no double effect', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberId = uuid.v4();
    final opId = uuid.v4();

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'House',
            creatorMemberId: memberId,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final op = harness.opFactory.auditLogAppend(
      opId: opId,
      houseId: houseId,
      logId: uuid.v4(),
      taskId: uuid.v4(),
      actorMemberId: memberId,
      action: 'claim',
    );

    await harness.apply(op, houseId);
    await harness.apply(op, houseId);

    final logs = await harness.db.select(harness.db.auditLogAppendOnly).get();
    expect(logs.length, 1);
  });
}
