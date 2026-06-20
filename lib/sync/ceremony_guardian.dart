import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';

class RotationRosterMember {
  const RotationRosterMember({
    required this.memberId,
    required this.rotationOrderIndex,
  });

  final String memberId;
  final int rotationOrderIndex;
}

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

/// Picks the next guardian in rotation order, wrapping around the active roster.
String pickNextGuardian({
  required String previousGuardianId,
  required List<RotationRosterMember> activeRoster,
  required int previousGuardianRotationIndex,
}) {
  if (activeRoster.isEmpty) {
    throw ArgumentError.value(
      activeRoster,
      'activeRoster',
      'must not be empty',
    );
  }

  final sorted = [...activeRoster]
    ..sort((a, b) => a.rotationOrderIndex.compareTo(b.rotationOrderIndex));

  final currentIndex =
      sorted.indexWhere((member) => member.memberId == previousGuardianId);
  if (currentIndex >= 0) {
    return sorted[(currentIndex + 1) % sorted.length].memberId;
  }

  for (final member in sorted) {
    if (member.rotationOrderIndex > previousGuardianRotationIndex) {
      return member.memberId;
    }
  }
  return sorted.first.memberId;
}

/// Resolves the guardian for cycle activation using rotation or first-cycle rules.
String resolveGuardianForActivation({
  required String cycleId,
  required List<String> activeMemberIds,
  required List<RotationRosterMember> activeRotationRoster,
  String? previousCycleGuardianId,
  required int? previousGuardianRotationIndex,
}) {
  if (previousCycleGuardianId == null) {
    return pickDeterministicGuardian(cycleId, activeMemberIds);
  }
  return pickNextGuardian(
    previousGuardianId: previousCycleGuardianId,
    activeRoster: activeRotationRoster,
    previousGuardianRotationIndex: previousGuardianRotationIndex!,
  );
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
