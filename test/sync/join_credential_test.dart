import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_operation.dart';

void main() {
  late JoinCredentialService service;
  late String secret;

  setUp(() {
    service = JoinCredentialService();
    secret = service.generateHouseSecret();
  });

  test('create and verify round-trip', () {
    final credential = service.create(houseId: 'house-1', houseSecret: secret);
    expect(service.verify(credential: credential, houseSecret: secret), isTrue);
    expect(credential.allowedOpType, SyncOpType.housemateCreate.wireValue);
  });

  test('expired credential fails verification', () {
    final credential = service.create(
      houseId: 'house-1',
      houseSecret: secret,
      ttl: const Duration(hours: -1),
    );
    expect(
      service.verify(credential: credential, houseSecret: secret),
      isFalse,
    );
  });

  test('replay rejected when nonce already consumed', () {
    final credential = service.create(houseId: 'house-1', houseSecret: secret);
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: {},
      localNodeKey: 'local-node',
      consumedCredentialNonces: {credential.nonce},
    );
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-1',
      houseId: 'house-1',
      senderDeviceId: 'device-x',
      senderTailscaleNodeKey: 'unknown-node',
      senderMemberId: null,
      hlc: 'aGxj',
      joinCredential: credential.encode(),
      ops: [
        SyncOperation(
          opId: 'op-1',
          opType: SyncOpType.housemateCreate.wireValue,
          houseId: 'house-1',
          originDeviceId: 'device-x',
          hlc: 'aGxj',
          payload: const {},
        ),
      ],
    );
    expect(
      allowlist
          .checkEnvelope(
            envelope,
            credentialService: service,
            houseJoinSecret: secret,
          )
          .allowed,
      isFalse,
    );
  });

  test('scoped op enforcement requires housemate_create', () {
    final credential = service.create(houseId: 'house-1', houseSecret: secret);
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: {},
      localNodeKey: 'local-node',
    );
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-2',
      houseId: 'house-1',
      senderDeviceId: 'device-x',
      senderTailscaleNodeKey: 'unknown-node',
      senderMemberId: null,
      hlc: 'aGxj',
      joinCredential: credential.encode(),
      ops: [
        SyncOperation(
          opId: 'op-2',
          opType: SyncOpType.auditLogAppend.wireValue,
          houseId: 'house-1',
          originDeviceId: 'device-x',
          hlc: 'aGxj',
          payload: const {},
        ),
      ],
    );
    expect(
      allowlist
          .checkEnvelope(
            envelope,
            credentialService: service,
            houseJoinSecret: secret,
          )
          .allowed,
      isFalse,
    );
  });

  test('generateHouseSecret produces 32+ bytes of entropy', () {
    final decoded = service.generateHouseSecret();
    expect(decoded.length, greaterThan(32));
  });
}
