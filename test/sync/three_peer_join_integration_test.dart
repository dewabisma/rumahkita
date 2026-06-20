import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/allowlist_strategy.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

Future<HandleEnvelopeResult> relayEnvelopeToPeer({
  required SyncTestHarness toHarness,
  required SyncService to,
  required String houseId,
  required SyncEnvelope envelope,
  required String toNodeKey,
}) async {
  final housemates = await (toHarness.db.select(
    toHarness.db.housematesSync,
  )..where((t) => t.houseId.equals(houseId))).get();
  final consumed = await (toHarness.db.select(
    toHarness.db.consumedJoinCredentials,
  )..where((t) => t.houseId.equals(houseId))).get();
  final strategy = RosterAllowlistStrategy(
    PeerAllowlist(
      activeMemberNodeKeys: housemates
          .where((m) => m.memberStatus == 'active')
          .map((m) => m.tailscaleNodeKey)
          .toSet(),
      localNodeKey: toNodeKey,
      consumedCredentialNonces: consumed.map((c) => c.nonce).toSet(),
    ),
  );
  return to.handleEnvelope(
    envelope,
    strategy: strategy,
    validationHouseId: houseId,
    ingressMode: AllowlistIngressMode.live,
    relay: false,
    consumeCredentials: true,
  );
}

Future<SyncEnvelope> latestJoinEnvelope(SyncTestHarness harness) async {
  final rows = await harness.db.select(harness.db.syncOutboxEntries).get();
  rows.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
  return SyncEnvelope.fromJson(
    jsonDecode(rows.last.envelopeJson) as Map<String, dynamic>,
  );
}

Future<void> bootstrapJoiner({
  required SyncTestHarness host,
  required SyncTestHarness joiner,
  required SyncService hostSync,
  required SyncService joinerSync,
  required String hostNodeKey,
  required JoinInvitePayload invite,
  required String nickname,
}) async {
  final joinerSettings = DriftLocalSettingsRepository(db: joiner.db);
  final catchUp = await hostSync.handleCatchUpRequestForTesting(
    CatchUpRequest(
      deviceId: joiner.deviceId,
      tailscaleNodeKey: joiner.nodeKey,
      houseId: invite.houseId,
      inviteHostNodeKey: hostNodeKey,
      joinCredential: invite.joinCredential,
    ),
  );

  await joinerSync.persistHouseJoinSecret(
    houseId: invite.houseId,
    secretBase64: catchUp.houseJoinSecret,
  );
  await joinerSync.applyRosterSnapshot(
    houseId: invite.houseId,
    rosterSnapshot: catchUp.rosterSnapshot,
  );
  await joinerSync.replayCatchUpOutbox(
    houseId: invite.houseId,
    trustedHostNodeKey: hostNodeKey,
    envelopes: catchUp.outboxReplay,
  );
  await joinerSettings.setActiveHouseId(invite.houseId);

  const uuid = Uuid();
  final memberId = uuid.v4();
  final rotationIndex = await joiner.housemateRepository.nextRotationIndex(
    invite.houseId,
  );

  await joiner.housemateRepository.joinHousemate(
    houseId: invite.houseId,
    memberId: memberId,
    tailscaleUserId: 'user-${joiner.deviceId}',
    tailscaleNodeKey: joiner.nodeKey,
    nickname: nickname,
    rotationOrderIndex: rotationIndex,
    joinCredential: invite.joinCredential,
  );

  final joinEnvelope = await latestJoinEnvelope(joiner);

  final relayResult = await relayEnvelopeToPeer(
    toHarness: host,
    to: hostSync,
    houseId: invite.houseId,
    envelope: joinEnvelope,
    toNodeKey: hostNodeKey,
  );
  expect(
    relayResult.applied,
    isTrue,
    reason: '$nickname join should apply on host',
  );
  expect(relayResult.mergeResult?.appliedOpIds, isNotEmpty);
}

SyncService buildSyncService(SyncTestHarness harness) {
  return SyncService(
    db: harness.db,
    syncWriteCoordinator: harness.syncCoordinator,
    meshService: TailscaleMeshService(
      stateDirectory: '/tmp/${harness.nodeKey}',
    ),
    transport: TailscaleSyncTransport(),
    joinCredentialService: harness.joinCredentialService,
    localSettings: DriftLocalSettingsRepository(db: harness.db),
  );
}

void main() {
  test(
    'host→B→C converge rosters, secrets match, nonces consumed on A and B',
    () async {
      final host = await SyncTestHarness.create(
        deviceId: 'device-host',
        nodeKey: 'node-host',
      );
      final peerB = await SyncTestHarness.create(
        deviceId: 'device-b',
        nodeKey: 'node-b',
      );
      final peerC = await SyncTestHarness.create(
        deviceId: 'device-c',
        nodeKey: 'node-c',
      );

      final hostSync = buildSyncService(host);
      final syncB = buildSyncService(peerB);
      final syncC = buildSyncService(peerC);

      const uuid = Uuid();
      final hostMemberId = uuid.v4();
      final house = await host.houseRepository.createHouse(
        displayName: 'Three Peer House',
        creatorMemberId: hostMemberId,
      );
      await host.housemateRepository.addCreatorHousemate(
        houseId: house.houseId,
        memberId: hostMemberId,
        tailscaleUserId: 'user-host',
        tailscaleNodeKey: host.nodeKey,
        nickname: 'Host',
      );

      final inviteB = await host.houseRepository.buildInvite(
        houseId: house.houseId,
        hostNodeKey: host.nodeKey,
        hostMagicDns: 'localhost',
      );

      await bootstrapJoiner(
        host: host,
        joiner: peerB,
        hostSync: hostSync,
        joinerSync: syncB,
        hostNodeKey: host.nodeKey,
        invite: inviteB,
        nickname: 'Roommate B',
      );

      expect(
        (await host.db.select(host.db.housematesSync).get()),
        hasLength(2),
      );

      // Relay B's state to C via outbox replay path — C catch-up from host.
      final inviteC = await host.houseRepository.buildInvite(
        houseId: house.houseId,
        hostNodeKey: host.nodeKey,
        hostMagicDns: 'localhost',
      );

      await bootstrapJoiner(
        host: host,
        joiner: peerC,
        hostSync: hostSync,
        joinerSync: syncC,
        hostNodeKey: host.nodeKey,
        invite: inviteC,
        nickname: 'Roommate C',
      );

      // Relay C join to B (mesh convergence).
      final cJoinEnvelope = await latestJoinEnvelope(peerC);
      final relayToB = await relayEnvelopeToPeer(
        toHarness: peerB,
        to: syncB,
        houseId: house.houseId,
        envelope: cJoinEnvelope,
        toNodeKey: peerB.nodeKey,
      );
      expect(relayToB.applied, isTrue);

      final rosterHost = await host.db.select(host.db.housematesSync).get();
      final rosterB = await peerB.db.select(peerB.db.housematesSync).get();
      final rosterC = await peerC.db.select(peerC.db.housematesSync).get();

      expect(rosterHost, hasLength(3));
      expect(rosterB, hasLength(3));
      expect(rosterC, hasLength(3));

      final nicknames = rosterHost.map((m) => m.nickname).toSet();
      expect(nicknames, {'Host', 'Roommate B', 'Roommate C'});

      final secretHost = await host.db
          .select(host.db.houseJoinSecrets)
          .getSingle();
      final secretB = await peerB.db
          .select(peerB.db.houseJoinSecrets)
          .getSingle();
      final secretC = await peerC.db
          .select(peerC.db.houseJoinSecrets)
          .getSingle();
      expect(secretB.secretBase64, secretHost.secretBase64);
      expect(secretC.secretBase64, secretHost.secretBase64);

      final consumedHost = await host.db
          .select(host.db.consumedJoinCredentials)
          .get();
      final consumedB = await peerB.db
          .select(peerB.db.consumedJoinCredentials)
          .get();
      expect(consumedHost, hasLength(2));
      expect(consumedB, hasLength(1));
    },
  );
}
