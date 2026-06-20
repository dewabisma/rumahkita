import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/allowlist_strategy.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('catch-up HTTP round-trip over plain http', () async {
    final host = await SyncTestHarness.create(
      deviceId: 'device-host',
      nodeKey: 'node-host',
    );
    const uuid = Uuid();
    final memberId = uuid.v4();
    final house = await host.houseRepository.createHouse(
      displayName: 'HTTP House',
      creatorMemberId: memberId,
    );
    await host.housemateRepository.addCreatorHousemate(
      houseId: house.houseId,
      memberId: memberId,
      tailscaleUserId: 'user-host',
      tailscaleNodeKey: host.nodeKey,
      nickname: 'Host',
    );

    final joinCredential = await host.houseRepository.generateJoinCredential(
      house.houseId,
    );

    final hostSettings = DriftLocalSettingsRepository(db: host.db);
    final hostSync = SyncService(
      db: host.db,
      syncWriteCoordinator: host.syncCoordinator,
      meshService: TailscaleMeshService(stateDirectory: '/tmp/http-host'),
      transport: TailscaleSyncTransport(),
      joinCredentialService: host.joinCredentialService,
      localSettings: hostSettings,
    );

    final server = CatchUpServer();
    await server.start(hostSync.handleCatchUpRequestForTesting);

    try {
      final response = await const CatchUpClient().fetch(
        hostMagicDns: 'localhost',
        request: CatchUpRequest(
          deviceId: 'device-joiner',
          tailscaleNodeKey: 'node-joiner',
          houseId: house.houseId,
          inviteHostNodeKey: host.nodeKey,
          joinCredential: joinCredential,
        ),
      );

      expect(response.houseJoinSecret, isNotEmpty);
      expect(response.rosterSnapshot, hasLength(1));
      expect(response.rosterSnapshot.single['nickname'], 'Host');
      expect(response.outboxReplay, isNotEmpty);
    } finally {
      await server.stop();
    }
  });

  test('catch-up rejects unknown houseId', () async {
    final host = await SyncTestHarness.create(
      deviceId: 'device-host',
      nodeKey: 'node-host',
    );
    const uuid = Uuid();
    final memberId = uuid.v4();
    final house = await host.houseRepository.createHouse(
      displayName: 'Mismatch House',
      creatorMemberId: memberId,
    );
    final joinCredential = await host.houseRepository.generateJoinCredential(
      house.houseId,
    );

    final hostSettings = DriftLocalSettingsRepository(db: host.db);
    final hostSync = SyncService(
      db: host.db,
      syncWriteCoordinator: host.syncCoordinator,
      meshService: TailscaleMeshService(stateDirectory: '/tmp/mismatch-host'),
      transport: TailscaleSyncTransport(),
      joinCredentialService: host.joinCredentialService,
      localSettings: hostSettings,
    );

    final server = CatchUpServer();
    await server.start(hostSync.handleCatchUpRequestForTesting);

    try {
      await expectLater(
        const CatchUpClient().fetch(
          hostMagicDns: 'localhost',
          request: CatchUpRequest(
            deviceId: 'device-joiner',
            tailscaleNodeKey: 'node-joiner',
            houseId: 'nonexistent-house-id',
            inviteHostNodeKey: host.nodeKey,
            joinCredential: joinCredential,
          ),
        ),
        throwsA(isA<HttpException>()),
      );
    } finally {
      await server.stop();
    }
  });

  test('handleEnvelope is idempotent when ops already applied', () async {
    final host = await SyncTestHarness.create(
      deviceId: 'device-host',
      nodeKey: 'node-host',
    );
    final joiner = await SyncTestHarness.create(
      deviceId: 'device-joiner',
      nodeKey: 'node-joiner',
    );
    final localSettings = DriftLocalSettingsRepository(db: joiner.db);
    final sync = SyncService(
      db: joiner.db,
      syncWriteCoordinator: joiner.syncCoordinator,
      meshService: TailscaleMeshService(stateDirectory: '/tmp/idempotent'),
      transport: TailscaleSyncTransport(),
      joinCredentialService: joiner.joinCredentialService,
      localSettings: localSettings,
    );

    const uuid = Uuid();
    final memberId = uuid.v4();
    final house = await host.houseRepository.createHouse(
      displayName: 'Idempotent House',
      creatorMemberId: memberId,
    );

    final outbox = await host.db.select(host.db.syncOutboxEntries).get();
    final envelope = SyncEnvelope.fromJson(
      jsonDecode(outbox.first.envelopeJson) as Map<String, dynamic>,
    );

    await sync.persistHouseJoinSecret(
      houseId: house.houseId,
      secretBase64: (await host.db.select(host.db.houseJoinSecrets).getSingle())
          .secretBase64,
    );

    final strategy = BootstrapAllowlistStrategy(
      trustedHostNodeKey: host.nodeKey,
      houseId: house.houseId,
      rosterAllowlist: PeerAllowlist(
        activeMemberNodeKeys: {host.nodeKey},
        localNodeKey: joiner.nodeKey,
      ),
    );

    final first = await sync.handleEnvelope(
      envelope,
      strategy: strategy,
      validationHouseId: house.houseId,
      ingressMode: AllowlistIngressMode.outboxReplay,
      consumeCredentials: false,
      relay: false,
    );
    expect(first.applied, isTrue);

    final second = await sync.handleEnvelope(
      envelope,
      strategy: strategy,
      validationHouseId: house.houseId,
      ingressMode: AllowlistIngressMode.outboxReplay,
      consumeCredentials: false,
      relay: false,
    );
    expect(second.applied, isFalse);
  });
}
