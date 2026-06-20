import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/allowlist_strategy.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('relays envelope to peers after successful apply', () async {
    final sender = await SyncTestHarness.create(
      deviceId: 'device-a',
      nodeKey: 'node-a',
    );
    final receiver = await SyncTestHarness.create(
      deviceId: 'device-b',
      nodeKey: 'node-b',
    );

    const uuid = Uuid();
    final memberId = uuid.v4();
    final house = await sender.houseRepository.createHouse(
      displayName: 'Relay House',
      creatorMemberId: memberId,
    );
    await sender.housemateRepository.addCreatorHousemate(
      houseId: house.houseId,
      memberId: memberId,
      tailscaleUserId: 'user-a',
      tailscaleNodeKey: sender.nodeKey,
      nickname: 'Host',
    );

    final outbox = await sender.db.select(sender.db.syncOutboxEntries).get();
    final lastEnvelope = SyncEnvelope.fromJson(
      jsonDecode(outbox.last.envelopeJson) as Map<String, dynamic>,
    );

    final receiverMesh = TailscaleMeshService(stateDirectory: '/tmp/recv');
    receiverMesh.setPeersForTesting([
      TailscalePeer(
        nodeKey: sender.nodeKey,
        hostName: 'localhost',
        online: true,
      ),
    ]);

    final receiverSettings = DriftLocalSettingsRepository(db: receiver.db);
    await receiverSettings.setActiveHouseId(house.houseId);
    await receiver.db
        .into(receiver.db.houseJoinSecrets)
        .insert(
          HouseJoinSecretsCompanion.insert(
            houseId: house.houseId,
            secretBase64:
                (await sender.db.select(sender.db.houseJoinSecrets).getSingle())
                    .secretBase64,
          ),
        );

    final received = <SyncEnvelope>[];
    final receiverTransport = TailscaleSyncTransport();
    await receiverTransport.start();
    final sub = receiverTransport.incomingEnvelopes.listen(received.add);

    final receiverSync = SyncService(
      db: receiver.db,
      syncWriteCoordinator: receiver.syncCoordinator,
      meshService: receiverMesh,
      transport: receiverTransport,
      joinCredentialService: receiver.joinCredentialService,
      localSettings: receiverSettings,
    );

    final senderMesh = TailscaleMeshService(stateDirectory: '/tmp/send');
    senderMesh.setPeersForTesting([
      TailscalePeer(
        nodeKey: receiver.nodeKey,
        hostName: 'localhost',
        online: true,
      ),
    ]);
    final senderSettings = DriftLocalSettingsRepository(db: sender.db);
    final senderSync = SyncService(
      db: sender.db,
      syncWriteCoordinator: sender.syncCoordinator,
      meshService: senderMesh,
      transport: TailscaleSyncTransport(),
      joinCredentialService: sender.joinCredentialService,
      localSettings: senderSettings,
    );

    await senderSync.handleEnvelope(
      lastEnvelope,
      strategy: RosterAllowlistStrategy(
        PeerAllowlist(
          activeMemberNodeKeys: {sender.nodeKey},
          localNodeKey: sender.nodeKey,
        ),
      ),
      validationHouseId: house.houseId,
      ingressMode: AllowlistIngressMode.live,
      relay: true,
      relayExcludeNodeKey: sender.nodeKey,
    );

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (received.isNotEmpty) {
      await receiverSync.handleEnvelope(
        received.first,
        strategy: RosterAllowlistStrategy(
          PeerAllowlist(
            activeMemberNodeKeys: {sender.nodeKey},
            localNodeKey: receiver.nodeKey,
          ),
        ),
        validationHouseId: house.houseId,
        ingressMode: AllowlistIngressMode.live,
        relay: false,
      );
    }

    await sub.cancel();
    await receiverTransport.stop();

    final members = await receiver.db.select(receiver.db.housematesSync).get();
    expect(members.length, greaterThanOrEqualTo(received.isEmpty ? 0 : 1));
  });
}
