import 'dart:convert';

import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/sync_operation.dart';

class SyncOpFactory {
  SyncOpFactory({required this.hlcService, required this.deviceId});

  final HlcService hlcService;
  final String deviceId;

  String _encodeHlc() => base64Encode(hlcService.toBytes(hlcService.now()));

  SyncOperation houseCreate({
    required String opId,
    required String houseId,
    required String displayName,
    required String creatorMemberId,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.houseCreate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {
        'display_name': displayName,
        'creator_member_id': creatorMemberId,
        'rules_version': 0,
      },
    );
  }

  SyncOperation housemateCreate({
    required String opId,
    required String houseId,
    required String memberId,
    required String tailscaleUserId,
    required String tailscaleNodeKey,
    required String nickname,
    int? rotationOrderIndex,
    MemberStatus memberStatus = MemberStatus.active,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.housemateCreate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {
        'member_id': memberId,
        'tailscale_user_id': tailscaleUserId,
        'tailscale_node_key': tailscaleNodeKey,
        'nickname': nickname,
        if (rotationOrderIndex != null)
          'rotation_order_index': rotationOrderIndex,
        'member_status': memberStatus.wireValue,
      },
    );
  }

  SyncOperation rotationAssignment({
    required String opId,
    required String houseId,
    required String memberId,
    required int rotationOrderIndex,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.rotationAssignment.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {
        'member_id': memberId,
        'rotation_order_index': rotationOrderIndex,
      },
    );
  }

  SyncOperation auditLogAppend({
    required String opId,
    required String houseId,
    required String logId,
    required String taskId,
    required String actorMemberId,
    required String action,
    String? justificationNotes,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.auditLogAppend.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: actorMemberId,
      hlc: _encodeHlc(),
      payload: {
        'log_id': logId,
        'task_id': taskId,
        'actor_member_id': actorMemberId,
        'action': action,
        if (justificationNotes != null)
          'justification_notes': justificationNotes,
      },
    );
  }

  SyncOperation houseRulesVersionUpdate({
    required String opId,
    required String houseId,
    required int rulesVersion,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.houseRulesVersionUpdate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {'rules_version': rulesVersion},
    );
  }

  SyncOperation housePrivilegeTemplatesUpdate({
    required String opId,
    required String houseId,
    required Map<String, dynamic> templatesJson,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.housePrivilegeTemplatesUpdate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {'privilege_templates': templatesJson},
    );
  }

  SyncOperation cycleCreate({
    required String opId,
    required String houseId,
    required String cycleId,
    required String activeGuardianMemberId,
    String status = 'drafting',
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.cycleCreate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {
        'cycle_id': cycleId,
        'active_guardian_member_id': activeGuardianMemberId,
        'status': status,
      },
    );
  }

  SyncOperation cycleSignoffSet({
    required String opId,
    required String houseId,
    required String cycleId,
    required String memberId,
    required bool accepted,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.cycleSignoffSet.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: memberId,
      hlc: _encodeHlc(),
      payload: {
        'cycle_id': cycleId,
        'member_id': memberId,
        'accepted': accepted,
      },
    );
  }

  SyncOperation cycleStatusTransition({
    required String opId,
    required String houseId,
    required String cycleId,
    String? from,
    required String to,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.cycleStatusTransition.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {'cycle_id': cycleId, if (from != null) 'from': from, 'to': to},
    );
  }

  SyncOperation cycleGuardianUpdate({
    required String opId,
    required String houseId,
    required String cycleId,
    required String activeGuardianMemberId,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.cycleGuardianUpdate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {
        'cycle_id': cycleId,
        'active_guardian_member_id': activeGuardianMemberId,
      },
    );
  }

  SyncOperation taskCreate({
    required String opId,
    required String houseId,
    required String taskId,
    required String cycleId,
    required String title,
    required int negotiatedPoints,
    String status = 'open',
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.taskCreate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {
        'task_id': taskId,
        'cycle_id': cycleId,
        'title': title,
        'negotiated_points': negotiatedPoints,
        'status': status,
      },
    );
  }

  SyncOperation taskFieldUpdate({
    required String opId,
    required String houseId,
    required String taskId,
    required String field,
    required Object value,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.taskFieldUpdate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: _encodeHlc(),
      payload: {'task_id': taskId, 'field': field, 'value': value},
    );
  }

  SyncOperation taskStatusUpdate({
    required String opId,
    required String houseId,
    required String taskId,
    required String actorMemberId,
    required TaskStatus from,
    required TaskStatus to,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.taskFieldUpdate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: actorMemberId,
      hlc: _encodeHlc(),
      payload: {
        'task_id': taskId,
        'field': 'status',
        'value': to.wireValue,
        'from': from.wireValue,
      },
    );
  }

  SyncOperation taskClaim({
    required String opId,
    required String houseId,
    required String eventId,
    required String taskId,
    required String memberId,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.taskClaim.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: memberId,
      hlc: _encodeHlc(),
      payload: {'event_id': eventId, 'task_id': taskId, 'member_id': memberId},
    );
  }

  SyncOperation scoreEventAppend({
    required String opId,
    required String houseId,
    required String eventId,
    required String memberId,
    required int delta,
    String? reasonRef,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.scoreEventAppend.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: memberId,
      hlc: _encodeHlc(),
      payload: {
        'event_id': eventId,
        'member_id': memberId,
        'delta': delta,
        if (reasonRef != null) 'reason_ref': reasonRef,
      },
    );
  }
}
