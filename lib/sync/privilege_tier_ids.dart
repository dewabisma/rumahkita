import 'dart:convert';

import 'package:crypto/crypto.dart';

String crossingTaskId(String templateId) => 'privilege:$templateId';

String crossingLogId({
  required String houseId,
  required String memberId,
  required String templateId,
  required String direction,
  required String triggeringEventId,
}) {
  final input =
      '$houseId|$memberId|$templateId|$direction|$triggeringEventId';
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString().substring(0, 32);
}

String crossingAuditOpId(String logId) {
  final digest = sha256.convert(utf8.encode('op|$logId'));
  return digest.toString().substring(0, 32);
}
