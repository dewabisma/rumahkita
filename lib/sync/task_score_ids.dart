import 'dart:convert';

import 'package:crypto/crypto.dart';

String taskApproveReasonRef(String taskId) => 'task_approve:$taskId';

String taskApproveScoreEventId({
  required String houseId,
  required String memberId,
  required String taskId,
}) {
  final input = '$houseId|$memberId|${taskApproveReasonRef(taskId)}';
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString().substring(0, 32);
}

/// Splits [base] points across sorted [claimantIds].
/// First `base % n` members (in sort order) receive one extra point.
Map<String, int> splitTaskPoints({
  required int base,
  required List<String> claimantIds,
}) {
  if (claimantIds.isEmpty) {
    return {};
  }
  final sorted = [...claimantIds]..sort();
  final n = sorted.length;
  final quotient = base ~/ n;
  final remainder = base % n;
  final result = <String, int>{};
  for (var i = 0; i < sorted.length; i++) {
    result[sorted[i]] = quotient + (i < remainder ? 1 : 0);
  }
  return result;
}
