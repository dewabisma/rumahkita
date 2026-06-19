import 'dart:convert';

import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/sync_operation.dart';

class SyncOpFactory {
  SyncOpFactory({
    required this.hlcService,
    required this.deviceId,
  });

  final HlcService hlcService;
  final String deviceId;

  String _encodeHlc() =>
      base64Encode(hlcService.toBytes(hlcService.now()));

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
}
