import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_operation.dart';

class MergeContext {
  MergeContext({
    required this.houseId,
    required this.activeMemberNodeKeys,
    required this.localNodeKey,
    required this.appliedOpIds,
    required this.memberStatusById,
    this.senderMemberId,
    this.joinCredentialBypass = false,
  });

  final String houseId;
  final Set<String> activeMemberNodeKeys;
  final String localNodeKey;
  final Set<String> appliedOpIds;
  final Map<String, MemberStatus> memberStatusById;
  final String? senderMemberId;
  final bool joinCredentialBypass;

  bool isOpApplied(String opId) => appliedOpIds.contains(opId);

  bool isMemberActive(String? memberId) {
    if (memberId == null) {
      return true;
    }
    final status = memberStatusById[memberId];
    return status == null || status == MemberStatus.active;
  }

  bool isMemberEvicted(String? memberId) {
    if (memberId == null) {
      return false;
    }
    return memberStatusById[memberId] == MemberStatus.evicted;
  }

  bool isExecutionOp(String opType) {
    return opType == SyncOpType.proposalStatusTransition.wireValue ||
        opType == SyncOpType.memberStatusTransition.wireValue;
  }

  TombstoneCheckResult checkEnvelopeTombstones(List<SyncOperation> ops) {
    for (final op in ops) {
      final result = checkTombstone(
        senderMemberId: senderMemberId,
        actorMemberId: op.actorMemberId,
        opType: op.opType,
      );
      if (!result.allowed) {
        return result;
      }
    }
    return const TombstoneCheckResult.allow();
  }

  TombstoneCheckResult checkTombstone({
    required String? senderMemberId,
    required String? actorMemberId,
    required String opType,
  }) {
    if (senderMemberId != null && isMemberEvicted(senderMemberId)) {
      return const TombstoneCheckResult.reject(RejectReason.evictedSender);
    }
    if (actorMemberId != null &&
        isMemberEvicted(actorMemberId) &&
        !isExecutionOp(opType)) {
      return const TombstoneCheckResult.reject(RejectReason.evictedActor);
    }
    return const TombstoneCheckResult.allow();
  }
}

class TombstoneCheckResult {
  const TombstoneCheckResult.allow() : allowed = true, reason = null;

  const TombstoneCheckResult.reject(this.reason) : allowed = false;

  final bool allowed;
  final RejectReason? reason;
}
