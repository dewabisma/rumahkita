import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/allowlist_strategy.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/data/repositories/secure_key_value_store.dart';

class HandleEnvelopeResult {
  const HandleEnvelopeResult({
    required this.applied,
    this.mergeResult,
    this.rejectReason,
    this.credentialNonce,
  });

  final bool applied;
  final MergeResult? mergeResult;
  final RejectReason? rejectReason;
  final String? credentialNonce;

  bool get success => applied;
}

/// Single ingress point for sync envelopes — replaces [SyncCoordinator].
class SyncService {
  SyncService({
    required this.db,
    required this.syncWriteCoordinator,
    required this.meshService,
    required this.transport,
    required this.joinCredentialService,
    required this.localSettings,
    CatchUpServer? catchUpServer,
    CatchUpClient? catchUpClient,
  })  : _catchUpServer = catchUpServer ?? CatchUpServer(),
        _catchUpClient = catchUpClient ?? const CatchUpClient();

  final AppDatabase db;
  final SyncWriteCoordinator syncWriteCoordinator;
  final TailscaleMeshService meshService;
  final TailscaleSyncTransport transport;
  final JoinCredentialService joinCredentialService;
  final LocalSettingsRepository localSettings;
  final CatchUpServer _catchUpServer;
  final CatchUpClient _catchUpClient;

  List<TailscalePeer> connectedPeers = [];
  int pendingOpCount = 0;
  String? lastError;
  MergeResult? lastMergeResult;

  final Set<String> _appliedEnvelopeIds = {};

  Future<void> start() async {
    await transport.start();
    transport.incomingEnvelopes.listen(_onLiveEnvelope);
    await _catchUpServer.start(_handleCatchUpRequest);
    connectedPeers = meshService.peers;
    await refreshPendingCount();
  }

  Future<void> stop() async {
    await transport.stop();
    await _catchUpServer.stop();
  }

  Future<void> refreshPendingCount() async {
    pendingOpCount = await syncWriteCoordinator.pendingOpCount();
  }

  /// Sole public ingress for envelopes.
  Future<HandleEnvelopeResult> handleEnvelope(
    SyncEnvelope envelope, {
    required AllowlistStrategy strategy,
    required String validationHouseId,
    required AllowlistIngressMode ingressMode,
    bool consumeCredentials = true,
    String? relayExcludeNodeKey,
    bool relay = true,
  }) async {
    final protocol = SyncEnvelopeValidator.validateProtocol(envelope);
    if (!protocol.isValid) {
      lastError = protocol.reason?.name;
      return HandleEnvelopeResult(
        applied: false,
        rejectReason: protocol.reason,
      );
    }

    final houseCheck =
        SyncEnvelopeValidator.validateHouse(envelope, validationHouseId);
    if (!houseCheck.isValid) {
      lastError = houseCheck.reason?.name;
      return HandleEnvelopeResult(
        applied: false,
        rejectReason: houseCheck.reason,
      );
    }

    if (await _isEnvelopeAlreadyApplied(envelope)) {
      return const HandleEnvelopeResult(applied: false);
    }

    final secret = await _houseSecret(validationHouseId);
    final allowResult = strategy.checkEnvelope(
      envelope,
      mode: ingressMode,
      credentialService: joinCredentialService,
      houseJoinSecret: secret,
    );
    if (!allowResult.allowed) {
      lastError = allowResult.reason?.name;
      return HandleEnvelopeResult(
        applied: false,
        rejectReason: allowResult.reason,
      );
    }

    final context = await syncWriteCoordinator.buildMergeContext(
      validationHouseId,
      senderMemberId: envelope.senderMemberId,
    );
    final tombstone = context.checkEnvelopeTombstones(envelope.ops);
    if (!tombstone.allowed) {
      lastError = tombstone.reason?.name;
      return HandleEnvelopeResult(
        applied: false,
        rejectReason: tombstone.reason,
      );
    }

    final mergeResult = await syncWriteCoordinator.ingestEnvelope(envelope);
    lastMergeResult = mergeResult;

    if (!mergeResult.success) {
      lastError = mergeResult.error ?? 'merge rejected';
      return HandleEnvelopeResult(
        applied: false,
        mergeResult: mergeResult,
        rejectReason: RejectReason.mergeRejected,
      );
    }

    if (mergeResult.appliedOpIds.isEmpty) {
      lastError = null;
      return HandleEnvelopeResult(
        applied: false,
        mergeResult: mergeResult,
      );
    }

    _appliedEnvelopeIds.add(envelope.envelopeId);
    await _markOutboxBroadcasted(envelope.envelopeId);

    final housemateCreateApplied = mergeResult.appliedOpIds.any(
      (appliedId) => envelope.ops.any(
        (op) =>
            op.opId == appliedId &&
            op.opType == SyncOpType.housemateCreate.wireValue,
      ),
    );

    if (consumeCredentials &&
        ingressMode == AllowlistIngressMode.live &&
        allowResult.credentialNonce != null &&
        housemateCreateApplied) {
      await db.into(db.consumedJoinCredentials).insert(
            ConsumedJoinCredentialsCompanion.insert(
              nonce: allowResult.credentialNonce!,
              houseId: validationHouseId,
              consumedByNodeKey: envelope.senderTailscaleNodeKey,
              consumedAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    lastError = null;
    await refreshPendingCount();

    if (relay) {
      await _relayEnvelope(
        envelope,
        excludeNodeKey: relayExcludeNodeKey ?? envelope.senderTailscaleNodeKey,
      );
    }

    return HandleEnvelopeResult(
      applied: true,
      mergeResult: mergeResult,
      credentialNonce: allowResult.credentialNonce,
    );
  }

  Future<void> _onLiveEnvelope(SyncEnvelope envelope) async {
    final activeHouseId = await localSettings.getActiveHouseId();
    if (activeHouseId == null) {
      lastError = 'No active house';
      return;
    }

    final strategy = await _rosterStrategy(activeHouseId);
    await handleEnvelope(
      envelope,
      strategy: strategy,
      validationHouseId: activeHouseId,
      ingressMode: AllowlistIngressMode.live,
      consumeCredentials: true,
    );
  }

  Future<CatchUpResponse> _handleCatchUpRequest(CatchUpRequest request) async {
    if (request.inviteHostNodeKey.isEmpty) {
      throw const FormatException('Missing invite_host_node_key');
    }

    final settings = await localSettings.getTailscaleNodeKey();
    if (settings != request.inviteHostNodeKey) {
      throw const FormatException('Not the invite host');
    }

    final secretRow = await (db.select(db.houseJoinSecrets)
          ..where((t) => t.houseId.equals(request.houseId)))
        .getSingleOrNull();
    if (secretRow == null) {
      throw const FormatException('House not found');
    }

    final parsed = joinCredentialService.parse(request.joinCredential);
    if (parsed == null ||
        !joinCredentialService.verify(
          credential: parsed,
          houseSecret: secretRow.secretBase64,
        )) {
      throw const FormatException('Invalid join credential');
    }

    final housemates = await (db.select(db.housematesSync)
          ..where((t) => t.houseId.equals(request.houseId)))
        .get();
    final rosterSnapshot = housemates
        .map(
          (m) => {
            'member_id': m.memberId,
            'nickname': m.nickname,
            'tailscale_user_id': m.tailscaleUserId,
            'tailscale_node_key': m.tailscaleNodeKey,
            'rotation_order_index': m.rotationOrderIndex,
            'member_status': m.memberStatus,
          },
        )
        .toList();

    final outboxRows = await (db.select(db.syncOutboxEntries)
          ..where((t) => t.houseId.equals(request.houseId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
        .get();

    final outboxReplay = outboxRows
        .map(
          (row) => SyncEnvelope.fromJson(
            jsonDecode(row.envelopeJson) as Map<String, dynamic>,
          ),
        )
        .toList();

    return CatchUpResponse(
      houseJoinSecret: secretRow.secretBase64,
      rosterSnapshot: rosterSnapshot,
      outboxReplay: outboxReplay,
    );
  }

  /// Joiner bootstrap: catch-up from host.
  Future<CatchUpResponse> performCatchUp({
    required String hostMagicDns,
    required CatchUpRequest request,
  }) =>
      _catchUpClient.fetch(
        hostMagicDns: hostMagicDns,
        request: request,
      );

  /// Test helper exposing catch-up handler without HTTP.
  Future<CatchUpResponse> handleCatchUpRequestForTesting(
    CatchUpRequest request,
  ) =>
      _handleCatchUpRequest(request);

  Future<void> applyRosterSnapshot({
    required String houseId,
    required List<Map<String, dynamic>> rosterSnapshot,
  }) async {
    final settings =
        await (db.select(db.localUserSettings)).getSingleOrNull();
    final updatedAtHlc = settings?.createdAtHlc ?? Uint8List(8);

    for (final member in rosterSnapshot) {
      final memberId = member['member_id'] as String;
      final existing = await (db.select(db.housematesSync)
            ..where((t) => t.memberId.equals(memberId)))
          .getSingleOrNull();
      if (existing != null) {
        continue;
      }

      final nodeKey = member['tailscale_node_key'] as String;
      await db.into(db.housematesSync).insert(
            HousematesSyncCompanion.insert(
              memberId: memberId,
              houseId: houseId,
              tailscaleUserId: member['tailscale_user_id'] as String? ??
                  'user-$nodeKey',
              tailscaleNodeKey: nodeKey,
              nickname: member['nickname'] as String,
              rotationOrderIndex:
                  Value(member['rotation_order_index'] as int?),
              memberStatus:
                  member['member_status'] as String? ?? 'active',
              updatedAtHlc: updatedAtHlc,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await db.into(db.syncPeerAllowlist).insert(
            SyncPeerAllowlistCompanion.insert(
              tailscaleNodeKey: nodeKey,
              houseId: houseId,
              memberId: Value(memberId),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> replayCatchUpOutbox({
    required String houseId,
    required String trustedHostNodeKey,
    required List<SyncEnvelope> envelopes,
  }) async {
    final strategy = BootstrapAllowlistStrategy(
      trustedHostNodeKey: trustedHostNodeKey,
      houseId: houseId,
      rosterAllowlist: await _buildPeerAllowlist(houseId),
    );

    for (final envelope in envelopes) {
      await handleEnvelope(
        envelope,
        strategy: strategy,
        validationHouseId: houseId,
        ingressMode: AllowlistIngressMode.outboxReplay,
        consumeCredentials: false,
        relay: false,
      );
    }
  }

  Future<void> persistHouseJoinSecret({
    required String houseId,
    required String secretBase64,
  }) async {
    await db.into(db.houseJoinSecrets).insert(
          HouseJoinSecretsCompanion.insert(
            houseId: houseId,
            secretBase64: secretBase64,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Removes house-scoped rows written during a partial join attempt.
  Future<void> discardPartialJoin(String houseId) async {
    await (db.delete(db.syncOutboxEntries)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.syncAppliedOps)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.syncPeerAllowlist)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.syncPeerState)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.housematesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.houseSync)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.houseJoinSecrets)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.cyclesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.tasksSync)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.taskClaimEvents)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.scoreEvents)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.removalProposalsSync)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.proposalVotesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.auditLogAppendOnly)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
    await (db.delete(db.consumedJoinCredentials)
          ..where((t) => t.houseId.equals(houseId)))
        .go();
  }

  Future<void> drainOutbox() async {
    final activeHouseId = await localSettings.getActiveHouseId();
    if (activeHouseId == null) {
      return;
    }

    final pending = await (db.select(db.syncOutboxEntries)
          ..where(
            (t) =>
                t.houseId.equals(activeHouseId) & t.broadcasted.equals(false),
          ))
        .get();

    for (final row in pending) {
      final envelope = SyncEnvelope.fromJson(
        jsonDecode(row.envelopeJson) as Map<String, dynamic>,
      );
      await _relayEnvelope(envelope, excludeNodeKey: null);
      await (db.update(db.syncOutboxEntries)
            ..where((t) => t.opId.equals(row.opId)))
          .write(const SyncOutboxEntriesCompanion(broadcasted: Value(true)));
    }
    await refreshPendingCount();
  }

  Future<RosterAllowlistStrategy> _rosterStrategy(String houseId) async {
    return RosterAllowlistStrategy(await _buildPeerAllowlist(houseId));
  }

  Future<PeerAllowlist> _buildPeerAllowlist(String houseId) async {
    final housemates = await (db.select(db.housematesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final nodeKey = await localSettings.getTailscaleNodeKey();
    final consumed = await (db.select(db.consumedJoinCredentials)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    return PeerAllowlist(
      activeMemberNodeKeys: housemates
          .where((m) => m.memberStatus == MemberStatus.active.wireValue)
          .map((m) => m.tailscaleNodeKey)
          .toSet(),
      localNodeKey: nodeKey,
      consumedCredentialNonces: consumed.map((c) => c.nonce).toSet(),
    );
  }

  Future<bool> _isEnvelopeAlreadyApplied(SyncEnvelope envelope) async {
    if (_appliedEnvelopeIds.contains(envelope.envelopeId)) {
      return true;
    }
    if (envelope.ops.isEmpty) {
      return false;
    }
    final context = await syncWriteCoordinator.buildMergeContext(
      envelope.houseId,
      senderMemberId: envelope.senderMemberId,
    );
    return envelope.ops.every((op) => context.isOpApplied(op.opId));
  }

  Future<void> _markOutboxBroadcasted(String envelopeId) async {
    await (db.update(db.syncOutboxEntries)
          ..where((t) => t.opId.equals(envelopeId)))
        .write(const SyncOutboxEntriesCompanion(broadcasted: Value(true)));
  }

  Future<void> _relayEnvelope(
    SyncEnvelope envelope, {
    required String? excludeNodeKey,
  }) async {
    for (final peer in meshService.peers) {
      if (peer.nodeKey == excludeNodeKey || !peer.online) {
        continue;
      }
      try {
        await transport.sendEnvelope(peer.hostName, envelope);
      } on Object {
        // Peer relay is best-effort.
      }
    }
  }

  Future<String?> _houseSecret(String houseId) async {
    final row = await (db.select(db.houseJoinSecrets)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    return row?.secretBase64;
  }
}

/// Tailscale mesh wrapper with stub/real switch.
class TailscaleMeshService {
  TailscaleMeshService({
    required this.stateDirectory,
    FlutterSecureStorage? secureStorage,
    SecureKeyValueStore? secureStore,
  }) : _secureStore = secureStore ??
            _FlutterSecureStorageAdapter(
              secureStorage ?? const FlutterSecureStorage(),
            );

  static const _authKeyKey = 'rumah_tailscale_auth_key';
  static const _authKeyStoredAtKey = 'rumah_tailscale_auth_key_stored_at';

  final String stateDirectory;
  final SecureKeyValueStore _secureStore;
  bool _isUp = false;
  final List<TailscalePeer> _peers = [];
  String? _localMagicDns;

  bool get isUp => _isUp;

  String? get localMagicDns => _localMagicDns;

  List<TailscalePeer> get peers => List.unmodifiable(_peers);

  static bool get useRealTailscale {
    const flag = bool.fromEnvironment('USE_REAL_TAILSCALE');
    return flag;
  }

  Future<void> up({String? authKey}) async {
    if (authKey != null) {
      await _secureStore.write(key: _authKeyKey, value: authKey);
      await _secureStore.write(
        key: _authKeyStoredAtKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    if (useRealTailscale) {
      // Real tailscale integration deferred — bind after registration.
      _isUp = true;
    } else {
      _isUp = true;
      _localMagicDns = 'localhost';
      _peers
        ..clear()
        ..addAll([
          const TailscalePeer(
            nodeKey: 'skeleton-peer',
            hostName: 'localhost',
            online: true,
          ),
        ]);
    }

    await _clearAuthKeyIfStale();
  }

  Future<void> down() async {
    _isUp = false;
    _peers.clear();
    _localMagicDns = null;
  }

  void setPeersForTesting(List<TailscalePeer> peers) {
    _peers
      ..clear()
      ..addAll(peers);
  }

  void setLocalMagicDnsForTesting(String dns) {
    _localMagicDns = dns;
  }

  Future<void> clearAuthKey() async {
    await _secureStore.delete(key: _authKeyKey);
    await _secureStore.delete(key: _authKeyStoredAtKey);
  }

  Future<void> _clearAuthKeyIfStale() async {
    final storedAt = await _secureStore.read(key: _authKeyStoredAtKey);
    if (storedAt == null) {
      return;
    }
    final ms = int.tryParse(storedAt);
    if (ms == null) {
      return;
    }
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ms),
    );
    if (age > const Duration(hours: 24)) {
      await clearAuthKey();
    }
  }
}

class _FlutterSecureStorageAdapter implements SecureKeyValueStore {
  const _FlutterSecureStorageAdapter(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);
}

class TailscalePeer {
  const TailscalePeer({
    required this.nodeKey,
    required this.hostName,
    required this.online,
  });

  final String nodeKey;
  final String hostName;
  final bool online;
}
