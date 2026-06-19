import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_operation.dart';

void main() {
  test('unknown node key rejected', () {
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: {'known-node'},
      localNodeKey: 'local-node',
    );
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-1',
      houseId: 'house-1',
      senderDeviceId: 'device-x',
      senderTailscaleNodeKey: 'unknown-node',
      senderMemberId: 'member-1',
      hlc: 'aGxj',
      ops: const [],
    );
    final result = allowlist.checkEnvelope(envelope);
    expect(result.allowed, isFalse);
  });

  test('inactive member node not in active set', () {
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: {},
      localNodeKey: 'local-node',
    );
    expect(allowlist.contains('inactive-node'), isFalse);
    expect(allowlist.contains('local-node'), isTrue);
  });

  test('own device always allowed', () {
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: {},
      localNodeKey: 'local-node',
    );
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-2',
      houseId: 'house-1',
      senderDeviceId: 'device-a',
      senderTailscaleNodeKey: 'local-node',
      senderMemberId: 'member-1',
      hlc: 'aGxj',
      ops: const [],
    );
    expect(allowlist.checkEnvelope(envelope).allowed, isTrue);
  });

  test('valid join credential admits unknown node with scoped op', () {
    final service = JoinCredentialService();
    final secret = service.generateHouseSecret();
    final credential = service.create(houseId: 'house-1', houseSecret: secret);
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: {},
      localNodeKey: 'local-node',
    );
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-3',
      houseId: 'house-1',
      senderDeviceId: 'device-joiner',
      senderTailscaleNodeKey: 'joiner-node',
      senderMemberId: null,
      hlc: 'aGxj',
      joinCredential: credential.encode(),
      ops: [
        SyncOperation(
          opId: 'op-join',
          opType: SyncOpType.housemateCreate.wireValue,
          houseId: 'house-1',
          originDeviceId: 'device-joiner',
          hlc: 'aGxj',
          payload: const {'member_id': 'member-new'},
        ),
      ],
    );
    final result = allowlist.checkEnvelope(
      envelope,
      credentialService: service,
      houseJoinSecret: secret,
    );
    expect(result.allowed, isTrue);
    expect(result.credentialNonce, credential.nonce);
  });
}
