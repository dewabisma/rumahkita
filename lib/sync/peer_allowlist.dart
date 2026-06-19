import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/sync_envelope.dart';

class PeerAllowlist {
  PeerAllowlist({
    required Set<String> activeMemberNodeKeys,
    required this.localNodeKey,
    this.consumedCredentialNonces = const {},
  }) : _activeKeys = {...activeMemberNodeKeys, localNodeKey};

  final Set<String> _activeKeys;
  final String localNodeKey;
  final Set<String> consumedCredentialNonces;

  int get size => _activeKeys.length;

  Set<String> get activeKeys => Set.unmodifiable(_activeKeys);

  bool contains(String nodeKey) => _activeKeys.contains(nodeKey);

  AllowlistCheckResult checkEnvelope(
    SyncEnvelope envelope, {
    JoinCredentialService? credentialService,
    String? houseJoinSecret,
  }) {
    if (contains(envelope.senderTailscaleNodeKey)) {
      return const AllowlistCheckResult.allowed();
    }

    if (envelope.joinCredential == null ||
        credentialService == null ||
        houseJoinSecret == null) {
      return const AllowlistCheckResult.rejected(
        RejectReason.peerNotAllowlisted,
      );
    }

    final parsed = credentialService.parse(envelope.joinCredential!);
    if (parsed == null) {
      return const AllowlistCheckResult.rejected(
        RejectReason.peerNotAllowlisted,
      );
    }

    if (consumedCredentialNonces.contains(parsed.nonce)) {
      return const AllowlistCheckResult.rejected(
        RejectReason.peerNotAllowlisted,
      );
    }

    if (!credentialService.verify(
      credential: parsed,
      houseSecret: houseJoinSecret,
    )) {
      return const AllowlistCheckResult.rejected(
        RejectReason.peerNotAllowlisted,
      );
    }

    final hasScopedOp = envelope.ops.any(
      (op) =>
          op.opType == SyncOpType.housemateCreate.wireValue &&
          op.houseId == parsed.houseId,
    );
    if (!hasScopedOp) {
      return const AllowlistCheckResult.rejected(
        RejectReason.peerNotAllowlisted,
      );
    }

    return AllowlistCheckResult.allowedWithCredential(parsed.nonce);
  }
}

class AllowlistCheckResult {
  const AllowlistCheckResult.allowed()
      : allowed = true,
        reason = null,
        credentialNonce = null;

  const AllowlistCheckResult.allowedWithCredential(this.credentialNonce)
      : allowed = true,
        reason = null;

  const AllowlistCheckResult.rejected(this.reason)
      : allowed = false,
        credentialNonce = null;

  final bool allowed;
  final RejectReason? reason;
  final String? credentialNonce;
}
