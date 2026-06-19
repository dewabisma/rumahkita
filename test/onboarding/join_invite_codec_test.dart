import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/services/join_invite_codec.dart';

void main() {
  const codec = JoinInviteCodec();

  test('round-trips invite payload through rumah:// URI', () {
    const payload = JoinInvitePayload(
      payloadVersion: joinInvitePayloadVersion,
      houseId: 'house-123',
      hostNodeKey: 'node-host',
      hostMagicDns: 'host.tailabc.ts.net',
      joinCredential: 'cred-abc',
    );

    final uri = codec.encode(payload);
    expect(uri, startsWith('rumah://join?p='));

    final decoded = codec.decode(uri);
    expect(decoded.houseId, payload.houseId);
    expect(decoded.hostNodeKey, payload.hostNodeKey);
    expect(decoded.hostMagicDns, payload.hostMagicDns);
    expect(decoded.joinCredential, payload.joinCredential);
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
        ),
      ),
      throwsFormatException,
    );
  });

  test('decodePayloadParam parses base64url segment', () {
    const payload = JoinInvitePayload(
      payloadVersion: joinInvitePayloadVersion,
      houseId: 'house-abc',
      hostNodeKey: 'node-a',
      hostMagicDns: 'a.ts.net',
      joinCredential: 'join-cred',
    );
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload.toJson())));
    final decoded = codec.decodePayloadParam(encoded);
    expect(decoded.houseId, 'house-abc');
  });
}
