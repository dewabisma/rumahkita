import 'dart:convert';

import 'package:crypto/crypto.dart';

String privilegeRedeemReasonRef(String redemptionId) =>
    'privilege_redeem:$redemptionId';

String privilegeRedemptionId({
  required String houseId,
  required String memberId,
  required String privilegeId,
  required String cycleId,
}) {
  final input = '$houseId|$memberId|$privilegeId|$cycleId';
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString().substring(0, 32);
}

String privilegeRedeemScoreEventId({
  required String houseId,
  required String memberId,
  required String redemptionId,
  required int purchaseIndex,
}) {
  final input =
      '$houseId|$memberId|${privilegeRedeemReasonRef(redemptionId)}|$purchaseIndex';
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString().substring(0, 32);
}

bool isPrivilegeRedeemReasonRef(String? reasonRef) =>
    reasonRef != null && reasonRef.startsWith('privilege_redeem:');

String redemptionIdFromReasonRef(String reasonRef) =>
    reasonRef.split(':').last;

String privilegeRedeemAuditLogId(String redemptionId) {
  final digest = sha256.convert(utf8.encode('redeem_audit|$redemptionId'));
  return digest.toString().substring(0, 32);
}

String privilegeRedeemAuditOpId(String logId) {
  final digest = sha256.convert(utf8.encode('op|$logId'));
  return digest.toString().substring(0, 32);
}
