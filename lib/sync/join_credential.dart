import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:uuid/uuid.dart';

/// Join credential format (JSON, base64url-encoded for wire transport):
///
/// ```json
/// {
///   "house_id": "<uuid>",
///   "allowed_op_type": "housemate_create",
///   "expiry_ms": 1710000000000,
///   "nonce": "<uuid>",
///   "signature": "<base64url HMAC-SHA256>"
/// }
/// ```
///
/// Signature is HMAC-SHA256 over:
/// `house_id|allowed_op_type|expiry_ms|nonce` using the house-scoped secret.
class JoinCredential {
  const JoinCredential({
    required this.houseId,
    required this.allowedOpType,
    required this.expiryMs,
    required this.nonce,
    required this.signature,
  });

  final String houseId;
  final String allowedOpType;
  final int expiryMs;
  final String nonce;
  final String signature;

  Map<String, dynamic> toJson() => {
    'house_id': houseId,
    'allowed_op_type': allowedOpType,
    'expiry_ms': expiryMs,
    'nonce': nonce,
    'signature': signature,
  };

  String encode() => base64Url.encode(utf8.encode(jsonEncode(toJson())));

  static JoinCredential? decode(String encoded) {
    try {
      final json =
          jsonDecode(utf8.decode(base64Url.decode(encoded)))
              as Map<String, dynamic>;
      return JoinCredential(
        houseId: json['house_id'] as String,
        allowedOpType: json['allowed_op_type'] as String,
        expiryMs: json['expiry_ms'] as int,
        nonce: json['nonce'] as String,
        signature: json['signature'] as String,
      );
    } on Object {
      return null;
    }
  }
}

class JoinCredentialService {
  JoinCredentialService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  String generateHouseSecret() {
    final bytes = Uint8List(32);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = Random.secure().nextInt(256);
    }
    return base64Url.encode(bytes);
  }

  JoinCredential create({
    required String houseId,
    required String houseSecret,
    Duration ttl = const Duration(hours: 24),
  }) {
    final nonce = _uuid.v4();
    final expiryMs = DateTime.now().add(ttl).millisecondsSinceEpoch;
    final signature = _sign(
      houseId: houseId,
      allowedOpType: SyncOpType.housemateCreate.wireValue,
      expiryMs: expiryMs,
      nonce: nonce,
      secret: houseSecret,
    );
    return JoinCredential(
      houseId: houseId,
      allowedOpType: SyncOpType.housemateCreate.wireValue,
      expiryMs: expiryMs,
      nonce: nonce,
      signature: signature,
    );
  }

  JoinCredential? parse(String encoded) => JoinCredential.decode(encoded);

  bool verify({
    required JoinCredential credential,
    required String houseSecret,
  }) {
    if (credential.allowedOpType != SyncOpType.housemateCreate.wireValue) {
      return false;
    }
    if (DateTime.now().millisecondsSinceEpoch > credential.expiryMs) {
      return false;
    }
    final expected = _sign(
      houseId: credential.houseId,
      allowedOpType: credential.allowedOpType,
      expiryMs: credential.expiryMs,
      nonce: credential.nonce,
      secret: houseSecret,
    );
    return expected == credential.signature;
  }

  String _sign({
    required String houseId,
    required String allowedOpType,
    required int expiryMs,
    required String nonce,
    required String secret,
  }) {
    final payload = '$houseId|$allowedOpType|$expiryMs|$nonce';
    final hmac = Hmac(sha256, utf8.encode(secret));
    return base64Url.encode(hmac.convert(utf8.encode(payload)).bytes);
  }
}
