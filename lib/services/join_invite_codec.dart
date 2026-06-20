import 'dart:convert';

import 'package:rumah/domain/entities/join_invite_payload.dart';

const String joinInviteScheme = 'rumah';
const String joinInviteHost = 'join';
const String joinInviteQueryParam = 'p';

class JoinInviteCodec {
  const JoinInviteCodec();

  String encode(JoinInvitePayload payload) {
    final json = jsonEncode(payload.toJson());
    final bytes = utf8.encode(json);
    if (bytes.length > joinInviteMaxDecodedBytes) {
      throw FormatException(
        'Join invite payload exceeds $joinInviteMaxDecodedBytes bytes',
      );
    }
    final encoded = base64Url.encode(bytes);
    return Uri(
      scheme: joinInviteScheme,
      host: joinInviteHost,
      queryParameters: {joinInviteQueryParam: encoded},
    ).toString();
  }

  JoinInvitePayload decode(String uriString) {
    final uri = Uri.parse(uriString.trim());
    if (uri.scheme != joinInviteScheme || uri.host != joinInviteHost) {
      throw FormatException('Invalid join invite URI scheme or host');
    }
    final encoded = uri.queryParameters[joinInviteQueryParam];
    if (encoded == null || encoded.isEmpty) {
      throw FormatException('Missing join invite payload parameter');
    }
    List<int> bytes;
    try {
      bytes = base64Url.decode(encoded);
    } on Object {
      throw const FormatException('Invalid base64url join invite payload');
    }
    if (bytes.length > joinInviteMaxDecodedBytes) {
      throw FormatException(
        'Join invite payload exceeds $joinInviteMaxDecodedBytes bytes',
      );
    }
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final version = (json['payload_version'] as num?)?.toInt();
    if (version != joinInvitePayloadVersion) {
      throw FormatException(
        version != null && version < joinInvitePayloadVersion
            ? 'This invite is outdated. Ask your roommate to share a new QR code.'
            : 'Unsupported invite payload version $version',
      );
    }
    final payload = JoinInvitePayload.fromJson(json);
    if (payload.tailscaleAuthKey.isEmpty) {
      throw const FormatException('Invite is missing Tailscale auth key');
    }
    return payload;
  }

  JoinInvitePayload decodePayloadParam(String encoded) {
    return decode(
      Uri(
        scheme: joinInviteScheme,
        host: joinInviteHost,
        queryParameters: {joinInviteQueryParam: encoded},
      ).toString(),
    );
  }
}
