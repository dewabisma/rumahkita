import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('first rotation assignment succeeds', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberId = uuid.v4();

    await harness.db
        .into(harness.db.housematesSync)
        .insert(
          HousematesSyncCompanion.insert(
            memberId: memberId,
            houseId: houseId,
            tailscaleUserId: 'user',
            tailscaleNodeKey: harness.nodeKey,
            nickname: 'Member',
            memberStatus: 'active',
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final result = await harness.apply(
      harness.opFactory.rotationAssignment(
        opId: uuid.v4(),
        houseId: houseId,
        memberId: memberId,
        rotationOrderIndex: 2,
      ),
      houseId,
    );
    expect(result.appliedOpIds.length, 1);

    final member = await (harness.db.select(
      harness.db.housematesSync,
    )..where((t) => t.memberId.equals(memberId))).getSingle();
    expect(member.rotationOrderIndex, 2);
  });

  test('second rotation assignment for same member rejected', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberId = uuid.v4();

    await harness.db
        .into(harness.db.housematesSync)
        .insert(
          HousematesSyncCompanion.insert(
            memberId: memberId,
            houseId: houseId,
            tailscaleUserId: 'user',
            tailscaleNodeKey: harness.nodeKey,
            nickname: 'Member',
            rotationOrderIndex: const Value(1),
            memberStatus: 'active',
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final result = await harness.apply(
      harness.opFactory.rotationAssignment(
        opId: uuid.v4(),
        houseId: houseId,
        memberId: memberId,
        rotationOrderIndex: 3,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });
}
