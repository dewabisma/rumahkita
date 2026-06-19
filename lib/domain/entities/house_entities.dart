import 'package:rumah/domain/enums/member_status.dart';

class House {
  const House({
    required this.houseId,
    required this.displayName,
    required this.creatorMemberId,
    required this.rulesVersion,
    required this.createdAtHlc,
    required this.updatedAtHlc,
  });

  final String houseId;
  final String displayName;
  final String creatorMemberId;
  final int rulesVersion;
  final List<int> createdAtHlc;
  final List<int> updatedAtHlc;
}

class Housemate {
  const Housemate({
    required this.memberId,
    required this.houseId,
    required this.tailscaleUserId,
    required this.tailscaleNodeKey,
    required this.nickname,
    required this.lifetimeScore,
    required this.rotationOrderIndex,
    required this.memberStatus,
    this.evictedAtHlc,
    required this.updatedAtHlc,
  });

  final String memberId;
  final String houseId;
  final String tailscaleUserId;
  final String tailscaleNodeKey;
  final String nickname;
  final int lifetimeScore;
  final int? rotationOrderIndex;
  final MemberStatus memberStatus;
  final List<int>? evictedAtHlc;
  final List<int> updatedAtHlc;
}

class AuditLogEntry {
  const AuditLogEntry({
    required this.logId,
    required this.houseId,
    required this.taskId,
    required this.actorMemberId,
    required this.action,
    this.justificationNotes,
    required this.hlc,
  });

  final String logId;
  final String houseId;
  final String taskId;
  final String actorMemberId;
  final String action;
  final String? justificationNotes;
  final List<int> hlc;
}
