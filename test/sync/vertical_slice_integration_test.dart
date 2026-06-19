import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('two peers converge on house, housemate, and audit log', () async {
    final peerA = await SyncTestHarness.create(
      deviceId: 'device-a',
      nodeKey: 'node-a',
    );
    final peerB = await SyncTestHarness.create(
      deviceId: 'device-b',
      nodeKey: 'node-b',
    );
    const uuid = Uuid();

    final memberId = uuid.v4();
    final house = await peerA.houseRepository.createHouse(
      displayName: 'Shared Home',
      creatorMemberId: memberId,
    );
    await peerA.housemateRepository.addCreatorHousemate(
      houseId: house.houseId,
      memberId: memberId,
      tailscaleUserId: 'user-a',
      tailscaleNodeKey: peerA.nodeKey,
      nickname: 'Creator',
    );
    await peerA.auditLogRepository.appendEntry(
      houseId: house.houseId,
      taskId: uuid.v4(),
      actorMemberId: memberId,
      action: 'claim',
    );

    final outbox = await peerA.db.select(peerA.db.syncOutboxEntries).get();
    expect(outbox, isNotEmpty);

    for (final row in outbox) {
      final envelope = SyncEnvelope.fromJson(
        jsonDecode(row.envelopeJson) as Map<String, dynamic>,
      );
      await peerB.syncCoordinator.ingestEnvelope(envelope);
    }

    final housesA = await peerA.db.select(peerA.db.houseSync).get();
    final housesB = await peerB.db.select(peerB.db.houseSync).get();
    final membersA = await peerA.db.select(peerA.db.housematesSync).get();
    final membersB = await peerB.db.select(peerB.db.housematesSync).get();
    final auditsA = await peerA.db.select(peerA.db.auditLogAppendOnly).get();
    final auditsB = await peerB.db.select(peerB.db.auditLogAppendOnly).get();

    expect(housesB.length, housesA.length);
    expect(membersB.length, membersA.length);
    expect(auditsB.length, auditsA.length);
    expect(housesB.single.displayName, 'Shared Home');
  });
}
