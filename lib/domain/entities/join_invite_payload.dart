import 'package:json_annotation/json_annotation.dart';

part 'join_invite_payload.g.dart';

const int joinInvitePayloadVersion = 2;
const int joinInviteMaxDecodedBytes = 4096;

@JsonSerializable(fieldRename: FieldRename.snake)
class JoinInvitePayload {
  const JoinInvitePayload({
    required this.payloadVersion,
    required this.houseId,
    required this.hostNodeKey,
    required this.hostMagicDns,
    required this.joinCredential,
    required this.tailscaleAuthKey,
  });

  final int payloadVersion;
  final String houseId;
  final String hostNodeKey;
  final String hostMagicDns;
  final String joinCredential;
  final String tailscaleAuthKey;

  JoinInvitePayload copyWith({
    int? payloadVersion,
    String? houseId,
    String? hostNodeKey,
    String? hostMagicDns,
    String? joinCredential,
    String? tailscaleAuthKey,
  }) {
    return JoinInvitePayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      houseId: houseId ?? this.houseId,
      hostNodeKey: hostNodeKey ?? this.hostNodeKey,
      hostMagicDns: hostMagicDns ?? this.hostMagicDns,
      joinCredential: joinCredential ?? this.joinCredential,
      tailscaleAuthKey: tailscaleAuthKey ?? this.tailscaleAuthKey,
    );
  }

  factory JoinInvitePayload.fromJson(Map<String, dynamic> json) =>
      _$JoinInvitePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$JoinInvitePayloadToJson(this);
}
