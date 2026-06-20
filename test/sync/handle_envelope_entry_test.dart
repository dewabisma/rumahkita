import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/allowlist_strategy.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test(
    'handleEnvelope validates bootstrap houseId not activeHouseId',
    () async {
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
        meshService: TailscaleMeshService(stateDirectory: '/tmp/test'),
        transport: TailscaleSyncTransport(),
        joinCredentialService: joiner.joinCredentialService,
        localSettings: localSettings,
      );

      const uuid = Uuid();
      final memberId = uuid.v4();
      final house = await host.houseRepository.createHouse(
        displayName: 'Bootstrap House',
        creatorMemberId: memberId,
      );

      final outbox = await host.db.select(host.db.syncOutboxEntries).get();
      final envelope = SyncEnvelope.fromJson(
        jsonDecode(outbox.first.envelopeJson) as Map<String, dynamic>,
      );

      await sync.persistHouseJoinSecret(
        houseId: house.houseId,
        secretBase64:
            (await host.db.select(host.db.houseJoinSecrets).getSingle())
                .secretBase64,
      );

      final result = await sync.handleEnvelope(
        envelope,
        strategy: BootstrapAllowlistStrategy(
          trustedHostNodeKey: host.nodeKey,
          houseId: house.houseId,
          rosterAllowlist: PeerAllowlist(
            activeMemberNodeKeys: {host.nodeKey},
            localNodeKey: joiner.nodeKey,
          ),
        ),
        validationHouseId: house.houseId,
        ingressMode: AllowlistIngressMode.outboxReplay,
        consumeCredentials: false,
        relay: false,
      );

      expect(result.applied, isTrue);
      final houses = await joiner.db.select(joiner.db.houseSync).get();
      expect(houses.single.houseId, house.houseId);
    },
  );
}
