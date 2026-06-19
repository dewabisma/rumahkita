import 'package:rumah/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('concurrent score deltas sum identically regardless of order', () async {
    final peerA = await SyncTestHarness.create(deviceId: 'a', nodeKey: 'node-a');
    final peerB = await SyncTestHarness.create(deviceId: 'b', nodeKey: 'node-b');
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberId = uuid.v4();

    for (final harness in [peerA, peerB]) {
      await harness.db.into(harness.db.housematesSync).insert(
            HousematesSyncCompanion.insert(
              memberId: memberId,
              houseId: houseId,
              tailscaleUserId: 'user',
              tailscaleNodeKey: harness.nodeKey,
              nickname: 'Tester',
              memberStatus: 'active',
              updatedAtHlc:
                  harness.hlcService.toBytes(harness.hlcService.now()),
            ),
          );
    }

    final opsA = [
      peerA.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 10,
      ),
      peerA.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: -3,
      ),
    ];
    final opsB = [
      peerB.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 5,
      ),
    ];

    for (final op in opsA) {
      await peerA.apply(op, houseId);
    }
    for (final op in opsB) {
      await peerA.apply(op, houseId);
    }
    for (final op in opsB) {
      await peerB.apply(op, houseId);
    }
    for (final op in opsA) {
      await peerB.apply(op, houseId);
    }

    final memberA = await (peerA.db.select(peerA.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();
    final memberB = await (peerB.db.select(peerB.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();

    expect(memberA.lifetimeScore, 12);
    expect(memberB.lifetimeScore, 12);
  });
}
