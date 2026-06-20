import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';

/// Picks a guardian deterministically from active members for a cycle.
String pickDeterministicGuardian(String cycleId, List<String> memberIds) {
  if (memberIds.isEmpty) {
    throw ArgumentError('memberIds must not be empty');
  }
  final sorted = [...memberIds]..sort();
  final hash = sha256.convert(utf8.encode(cycleId));
  final index =
      hash.bytes.fold<int>(0, (acc, byte) => acc + byte) % sorted.length;
  return sorted[index];
}

List<String> activeMemberIds(Map<String, MemberStatus> statusById) {
  return statusById.entries
      .where((e) => e.value == MemberStatus.active)
      .map((e) => e.key)
      .toList();
}

bool isActivationGateMet({
  required CycleStatus cycleStatus,
  required int rulesVersionAtSignoff,
  required int houseRulesVersion,
  required Map<String, dynamic> ceremonySignoffs,
  required List<String> activeMemberIds,
}) {
  if (cycleStatus != CycleStatus.drafting) {
    return false;
  }
  if (rulesVersionAtSignoff != houseRulesVersion) {
    return false;
  }
  if (activeMemberIds.isEmpty) {
    return false;
  }
  for (final memberId in activeMemberIds) {
    final entry = ceremonySignoffs[memberId];
    if (entry is! Map || entry['accepted'] != true) {
      return false;
    }
  }
  return true;
}

bool isTaskArchived(String statusWire) =>
    statusWire == TaskStatus.archived.wireValue;

bool isTaskReviewGuardian({
  required String activeGuardianMemberId,
  required String actorMemberId,
}) => activeGuardianMemberId == actorMemberId;
