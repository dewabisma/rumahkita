import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('catch-up replay does not consume join credential nonces', () async {
    final host = await SyncTestHarness.create(
      deviceId: 'device-host',
      nodeKey: 'node-host',
    );
    const uuid = Uuid();
    final memberId = uuid.v4();
    final house = await host.houseRepository.createHouse(
      displayName: 'Replay House',
      creatorMemberId: memberId,
    );
    await host.housemateRepository.addCreatorHousemate(
      houseId: house.houseId,
      memberId: memberId,
      tailscaleUserId: 'user-host',
      tailscaleNodeKey: host.nodeKey,
      nickname: 'Host',
    );

    final joinCredential =
        await host.houseRepository.generateJoinCredential(house.houseId);

    final joiner = await SyncTestHarness.create(
      deviceId: 'device-joiner',
      nodeKey: 'node-joiner',
    );
    final joinerSettings = DriftLocalSettingsRepository(db: joiner.db);
    final joinerSync = SyncService(
      db: joiner.db,
      syncWriteCoordinator: joiner.syncCoordinator,
      meshService: TailscaleMeshService(stateDirectory: '/tmp/joiner'),
      transport: TailscaleSyncTransport(),
      joinCredentialService: joiner.joinCredentialService,
      localSettings: joinerSettings,
    );

    final hostSettings = DriftLocalSettingsRepository(db: host.db);
    final hostSync = SyncService(
      db: host.db,
      syncWriteCoordinator: host.syncCoordinator,
      meshService: TailscaleMeshService(stateDirectory: '/tmp/host'),
      transport: TailscaleSyncTransport(),
      joinCredentialService: host.joinCredentialService,
      localSettings: hostSettings,
    );

    final catchUp = await hostSync.handleCatchUpRequestForTesting(
      CatchUpRequest(
        deviceId: 'device-joiner',
        tailscaleNodeKey: joiner.nodeKey,
        houseId: house.houseId,
        inviteHostNodeKey: host.nodeKey,
        joinCredential: joinCredential,
      ),
    );

    await joinerSync.persistHouseJoinSecret(
      houseId: house.houseId,
      secretBase64: catchUp.houseJoinSecret,
    );

    await joinerSync.applyRosterSnapshot(
      houseId: house.houseId,
      rosterSnapshot: catchUp.rosterSnapshot,
    );

    await joinerSync.replayCatchUpOutbox(
      houseId: house.houseId,
      trustedHostNodeKey: host.nodeKey,
      envelopes: catchUp.outboxReplay,
    );

    final consumedOnJoiner = await joiner.db
        .select(joiner.db.consumedJoinCredentials)
        .get();
    expect(consumedOnJoiner, isEmpty);

    final consumedOnHost =
        await host.db.select(host.db.consumedJoinCredentials).get();
    expect(consumedOnHost, isEmpty);

    final members = await joiner.db.select(joiner.db.housematesSync).get();
    expect(members, hasLength(1));
    expect(members.single.nickname, 'Host');
  });
}
