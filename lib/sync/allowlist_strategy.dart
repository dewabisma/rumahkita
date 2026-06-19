import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';

/// Ingress classification for allowlist decisions.
enum AllowlistIngressMode {
  /// Live transport or relay — full credential checks apply.
  live,

  /// Host-authenticated catch-up replay batch — historical envelopes admitted.
  outboxReplay,
}

abstract class AllowlistStrategy {
  AllowlistCheckResult checkEnvelope(
    SyncEnvelope envelope, {
    required AllowlistIngressMode mode,
    JoinCredentialService? credentialService,
    String? houseJoinSecret,
  });
}

/// Standard roster allowlist for post-bootstrap live ingress.
class RosterAllowlistStrategy implements AllowlistStrategy {
  RosterAllowlistStrategy(this._allowlist);

  final PeerAllowlist _allowlist;

  @override
  AllowlistCheckResult checkEnvelope(
    SyncEnvelope envelope, {
    required AllowlistIngressMode mode,
    JoinCredentialService? credentialService,
    String? houseJoinSecret,
  }) {
    return _allowlist.checkEnvelope(
      envelope,
      credentialService: credentialService,
      houseJoinSecret: houseJoinSecret,
    );
  }
}

/// Bootstrap-phase allowlist with replay batch admission (P2b).
class BootstrapAllowlistStrategy implements AllowlistStrategy {
  BootstrapAllowlistStrategy({
    required this.trustedHostNodeKey,
    required this.houseId,
    required PeerAllowlist rosterAllowlist,
  }) : _rosterAllowlist = rosterAllowlist;

  final String trustedHostNodeKey;
  final String houseId;
  final PeerAllowlist _rosterAllowlist;

  @override
  AllowlistCheckResult checkEnvelope(
    SyncEnvelope envelope, {
    required AllowlistIngressMode mode,
    JoinCredentialService? credentialService,
    String? houseJoinSecret,
  }) {
    if (envelope.houseId != houseId) {
      return const AllowlistCheckResult.rejected(RejectReason.houseMismatch);
    }

    // P2b: host-authenticated replay admits historical peer join envelopes.
    if (mode == AllowlistIngressMode.outboxReplay) {
      return const AllowlistCheckResult.allowed();
    }

    // P3: live ingress during bootstrap uses credential checks.
    if (envelope.senderTailscaleNodeKey == trustedHostNodeKey) {
      return const AllowlistCheckResult.allowed();
    }

    return _rosterAllowlist.checkEnvelope(
      envelope,
      credentialService: credentialService,
      houseJoinSecret: houseJoinSecret,
    );
  }
}

/// Factory helpers for building roster allowlists from DB state.
class AllowlistFactory {
  static bool envelopeHasScopedJoinOp(SyncEnvelope envelope, String houseId) {
    return envelope.ops.any(
      (op) =>
          op.opType == SyncOpType.housemateCreate.wireValue &&
          op.houseId == houseId,
    );
  }
}
