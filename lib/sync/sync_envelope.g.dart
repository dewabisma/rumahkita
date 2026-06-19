// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncEnvelope _$SyncEnvelopeFromJson(Map<String, dynamic> json) => SyncEnvelope(
  protocolVersion: (json['protocol_version'] as num).toInt(),
  envelopeId: json['envelope_id'] as String,
  houseId: json['house_id'] as String,
  senderDeviceId: json['sender_device_id'] as String,
  senderTailscaleNodeKey: json['sender_tailscale_node_key'] as String,
  senderMemberId: json['sender_member_id'] as String?,
  hlc: json['hlc'] as String,
  ops: (json['ops'] as List<dynamic>)
      .map((e) => SyncOperation.fromJson(e as Map<String, dynamic>))
      .toList(),
  vectorClock: (json['vector_clock'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  joinCredential: json['join_credential'] as String?,
);

Map<String, dynamic> _$SyncEnvelopeToJson(SyncEnvelope instance) =>
    <String, dynamic>{
      'protocol_version': instance.protocolVersion,
      'envelope_id': instance.envelopeId,
      'house_id': instance.houseId,
      'sender_device_id': instance.senderDeviceId,
      'sender_tailscale_node_key': instance.senderTailscaleNodeKey,
      'sender_member_id': instance.senderMemberId,
      'hlc': instance.hlc,
      'ops': instance.ops.map((e) => e.toJson()).toList(),
      'vector_clock': instance.vectorClock,
      'join_credential': instance.joinCredential,
    };
