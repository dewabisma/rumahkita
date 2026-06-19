import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';

class SyncCoordinator extends ChangeNotifier {
  SyncCoordinator({
    required this.db,
    required this.syncWriteCoordinator,
    required this.meshService,
    required this.transport,
    required this.joinCredentialService,
  });

  final AppDatabase db;
  final SyncWriteCoordinator syncWriteCoordinator;
  final TailscaleMeshService meshService;
  final TailscaleSyncTransport transport;
  final JoinCredentialService joinCredentialService;

  List<TailscalePeer> connectedPeers = [];
  int pendingOpCount = 0;
  String? lastError;
  MergeResult? lastMergeResult;

  Future<void> start() async {
    await transport.start();
    transport.incomingEnvelopes.listen(_onEnvelope);
    connectedPeers = meshService.peers;
    await refreshPendingCount();
    notifyListeners();
  }

  Future<void> refreshPendingCount() async {
    pendingOpCount = await syncWriteCoordinator.pendingOpCount();
    notifyListeners();
  }

  Future<void> _onEnvelope(SyncEnvelope envelope) async {
    final settings =
        await (db.select(db.localUserSettings)).getSingleOrNull();
    final activeHouseId = settings?.activeHouseId;
    if (activeHouseId == null) {
      lastError = 'No active house';
      notifyListeners();
      return;
    }

    final protocol = SyncEnvelopeValidator.validateProtocol(envelope);
    if (!protocol.isValid) {
      lastError = protocol.reason?.name;
      notifyListeners();
      return;
    }

    final houseCheck =
        SyncEnvelopeValidator.validateHouse(envelope, activeHouseId);
    if (!houseCheck.isValid) {
      lastError = houseCheck.reason?.name;
      notifyListeners();
      return;
    }

    final allowlist = await _buildAllowlist(activeHouseId);
    final secret = await _houseSecret(activeHouseId);
    final allowResult = allowlist.checkEnvelope(
      envelope,
      credentialService: joinCredentialService,
      houseJoinSecret: secret,
    );
    if (!allowResult.allowed) {
      lastError = allowResult.reason?.name;
      notifyListeners();
      return;
    }

    final context = await syncWriteCoordinator.buildMergeContext(
      activeHouseId,
      senderMemberId: envelope.senderMemberId,
    );
    final tombstone = context.checkEnvelopeTombstones(envelope.ops);
    if (!tombstone.allowed) {
      lastError = tombstone.reason?.name;
      notifyListeners();
      return;
    }

    lastMergeResult =
        await syncWriteCoordinator.ingestEnvelope(envelope);

    final housemateCreateApplied = lastMergeResult!.appliedOpIds.any(
      (appliedId) => envelope.ops.any(
        (op) =>
            op.opId == appliedId &&
            op.opType == SyncOpType.housemateCreate.wireValue,
      ),
    );

    if (allowResult.credentialNonce != null && housemateCreateApplied) {
      await db.into(db.consumedJoinCredentials).insert(
            ConsumedJoinCredentialsCompanion.insert(
              nonce: allowResult.credentialNonce!,
              houseId: activeHouseId,
              consumedByNodeKey: envelope.senderTailscaleNodeKey,
              consumedAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    lastError = lastMergeResult!.success
        ? null
        : (lastMergeResult!.error ?? 'merge rejected');
    await refreshPendingCount();
    notifyListeners();
  }

  Future<PeerAllowlist> _buildAllowlist(String houseId) async {
    final housemates = await (db.select(db.housematesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final settings = await (db.select(db.localUserSettings)).getSingleOrNull();
    final consumed = await (db.select(db.consumedJoinCredentials)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    return PeerAllowlist(
      activeMemberNodeKeys: housemates
          .where((m) => m.memberStatus == MemberStatus.active.wireValue)
          .map((m) => m.tailscaleNodeKey)
          .toSet(),
      localNodeKey: settings?.tailscaleNodeId ?? '',
      consumedCredentialNonces: consumed.map((c) => c.nonce).toSet(),
    );
  }

  Future<String?> _houseSecret(String houseId) async {
    final row = await (db.select(db.houseJoinSecrets)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    return row?.secretBase64;
  }
}
