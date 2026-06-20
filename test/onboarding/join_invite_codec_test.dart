import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/services/join_invite_codec.dart';

const _realisticTsKey =
    'tskey-auth-kABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghij';

JoinInvitePayload _samplePayload({int version = joinInvitePayloadVersion}) {
  return JoinInvitePayload(
    payloadVersion: version,
    houseId: 'house-123',
    hostNodeKey: 'node-host',
    hostMagicDns: 'host.tailabc.ts.net',
    joinCredential: 'cred-abc',
    tailscaleAuthKey: _realisticTsKey,
  );
}

void main() {
  const codec = JoinInviteCodec();

  test('round-trips invite payload through rumah:// URI', () {
    final payload = _samplePayload();

    final uri = codec.encode(payload);
    expect(uri, startsWith('rumah://join?p='));

    final decoded = codec.decode(uri);
    expect(decoded.houseId, payload.houseId);
    expect(decoded.hostNodeKey, payload.hostNodeKey);
    expect(decoded.hostMagicDns, payload.hostMagicDns);
    expect(decoded.joinCredential, payload.joinCredential);
    expect(decoded.tailscaleAuthKey, payload.tailscaleAuthKey);
  });

  test('rejects oversized payload', () {
    final huge = 'x' * 5000;
    expect(
      () => codec.encode(
        JoinInvitePayload(
          payloadVersion: joinInvitePayloadVersion,
          houseId: huge,
          hostNodeKey: 'node',
          hostMagicDns: 'host.ts.net',
          joinCredential: 'cred',
          tailscaleAuthKey: _realisticTsKey,
        ),
      ),
      throwsFormatException,
    );
  });

  test('rejects v1 payload with friendly message', () {
    final v1Json = jsonEncode({
      'payload_version': 1,
      'house_id': 'house-old',
      'host_node_key': 'node',
      'host_magic_dns': 'host.ts.net',
      'join_credential': 'cred',
    });
    final encoded = base64Url.encode(utf8.encode(v1Json));
    expect(
      () => codec.decodePayloadParam(encoded),
      throwsA(
        predicate<FormatException>(
          (e) => e.message.contains('outdated'),
        ),
      ),
    );
  });

  test('realistic tskey fits within size limit', () {
    final payload = _samplePayload();
    final uri = codec.encode(payload);
    expect(uri.length, lessThan(joinInviteMaxDecodedBytes * 2));
    expect(codec.decode(uri).tailscaleAuthKey, _realisticTsKey);
  });

  test('decodePayloadParam parses base64url segment', () {
    final payload = _samplePayload();
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload.toJson())));
    final decoded = codec.decodePayloadParam(encoded);
    expect(decoded.houseId, 'house-123');
    expect(decoded.tailscaleAuthKey, _realisticTsKey);
  });
}
