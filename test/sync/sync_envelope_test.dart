import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_operation.dart';

void main() {
  test('wrong protocol version rejected', () {
    final envelope = SyncEnvelope(
      protocolVersion: 99,
      envelopeId: 'env-1',
      houseId: 'house-1',
      senderDeviceId: 'device-a',
      senderTailscaleNodeKey: 'node-a',
      senderMemberId: 'member-a',
      hlc: base64Encode([1, 2, 3, 4, 5, 6, 7, 8]),
      ops: const [],
    );
    final result = SyncEnvelopeValidator.validateProtocol(envelope);
    expect(result.isValid, isFalse);
  });

  test('house_id mismatch rejected', () {
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-2',
      houseId: 'house-a',
      senderDeviceId: 'device-a',
      senderTailscaleNodeKey: 'node-a',
      senderMemberId: 'member-a',
      hlc: base64Encode([1, 2, 3, 4, 5, 6, 7, 8]),
      ops: [
        SyncOperation(
          opId: 'op-1',
          opType: 'audit_log_append',
          houseId: 'house-b',
          originDeviceId: 'device-a',
          hlc: base64Encode([1, 2, 3, 4, 5, 6, 7, 8]),
          payload: const {},
        ),
      ],
    );
    final result = SyncEnvelopeValidator.validateHouse(envelope, 'house-a');
    expect(result.isValid, isFalse);
  });

  test('round-trip codec', () {
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: 'env-3',
      houseId: 'house-1',
      senderDeviceId: 'device-a',
      senderTailscaleNodeKey: 'node-a',
      senderMemberId: 'member-a',
      hlc: base64Encode([1, 2, 3, 4, 5, 6, 7, 8]),
      ops: [
        SyncOperation(
          opId: 'op-1',
          opType: 'audit_log_append',
          houseId: 'house-1',
          originDeviceId: 'device-a',
          hlc: base64Encode([1, 2, 3, 4, 5, 6, 7, 8]),
          payload: const {'action': 'test'},
        ),
      ],
    );
    final decoded =
        SyncEnvelope.fromJson(jsonDecode(jsonEncode(envelope.toJson())));
    expect(decoded.envelopeId, envelope.envelopeId);
    expect(decoded.ops.first.payload['action'], 'test');
  });
}
