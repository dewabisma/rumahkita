// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_invite_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinInvitePayload _$JoinInvitePayloadFromJson(Map<String, dynamic> json) =>
    JoinInvitePayload(
      payloadVersion: (json['payload_version'] as num).toInt(),
      houseId: json['house_id'] as String,
      hostNodeKey: json['host_node_key'] as String,
      hostMagicDns: json['host_magic_dns'] as String,
      joinCredential: json['join_credential'] as String,
    );

Map<String, dynamic> _$JoinInvitePayloadToJson(JoinInvitePayload instance) =>
    <String, dynamic>{
      'payload_version': instance.payloadVersion,
      'house_id': instance.houseId,
      'host_node_key': instance.hostNodeKey,
      'host_magic_dns': instance.hostMagicDns,
      'join_credential': instance.joinCredential,
    };
