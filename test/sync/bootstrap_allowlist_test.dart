import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/allowlist_strategy.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_operation.dart';

void main() {
  const houseId = 'house-1';
  const hostKey = 'node-host';
  const joinerKey = 'node-joiner';

  SyncEnvelope envelope({
    required String senderKey,
    String? joinCredential,
    List<SyncOperation>? ops,
  }) {
    return SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-1',
      houseId: houseId,
      senderDeviceId: 'device-x',
      senderTailscaleNodeKey: senderKey,
      hlc: 'aGw=',
      ops: ops ??
          [
            SyncOperation(
              opId: 'op-1',
              opType: SyncOpType.housemateCreate.wireValue,
              houseId: houseId,
              originDeviceId: 'device-x',
              hlc: 'aGw=',
              payload: const {'member_id': 'm-1'},
            ),
          ],
      joinCredential: joinCredential,
    );
  }

  test('P2b: replay batch admits unknown sender without credential', () {
    final strategy = BootstrapAllowlistStrategy(
      trustedHostNodeKey: hostKey,
      houseId: houseId,
      rosterAllowlist: PeerAllowlist(
        activeMemberNodeKeys: {hostKey},
        localNodeKey: hostKey,
      ),
    );

    final result = strategy.checkEnvelope(
      envelope(senderKey: joinerKey),
      mode: AllowlistIngressMode.outboxReplay,
    );

    expect(result.allowed, isTrue);
  });

  test('P3: live ingress requires credential for unknown sender', () {
    final credService = JoinCredentialService();
    final secret = credService.generateHouseSecret();
    final credential = credService.create(houseId: houseId, houseSecret: secret);

    final strategy = BootstrapAllowlistStrategy(
      trustedHostNodeKey: hostKey,
      houseId: houseId,
      rosterAllowlist: PeerAllowlist(
        activeMemberNodeKeys: {hostKey},
        localNodeKey: hostKey,
      ),
    );

    final withoutCred = strategy.checkEnvelope(
      envelope(senderKey: joinerKey),
      mode: AllowlistIngressMode.live,
      credentialService: credService,
      houseJoinSecret: secret,
    );
    expect(withoutCred.allowed, isFalse);

    final withCred = strategy.checkEnvelope(
      envelope(
        senderKey: joinerKey,
        joinCredential: credential.encode(),
      ),
      mode: AllowlistIngressMode.live,
      credentialService: credService,
      houseJoinSecret: secret,
    );
    expect(withCred.allowed, isTrue);
    expect(withCred.credentialNonce, credential.nonce);
  });
}
