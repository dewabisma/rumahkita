// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncOperation _$SyncOperationFromJson(Map<String, dynamic> json) =>
    SyncOperation(
      opId: json['op_id'] as String,
      opType: json['op_type'] as String,
      houseId: json['house_id'] as String,
      originDeviceId: json['origin_device_id'] as String,
      hlc: json['hlc'] as String,
      actorMemberId: json['actor_member_id'] as String?,
      payload: json['payload'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SyncOperationToJson(SyncOperation instance) =>
    <String, dynamic>{
      'op_id': instance.opId,
      'op_type': instance.opType,
      'house_id': instance.houseId,
      'origin_device_id': instance.originDeviceId,
      'hlc': instance.hlc,
      'actor_member_id': instance.actorMemberId,
      'payload': instance.payload,
    };
