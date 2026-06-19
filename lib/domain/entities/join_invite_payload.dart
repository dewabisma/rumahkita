import 'package:json_annotation/json_annotation.dart';

part 'join_invite_payload.g.dart';

const int joinInvitePayloadVersion = 1;
const int joinInviteMaxDecodedBytes = 4096;

@JsonSerializable(fieldRename: FieldRename.snake)
class JoinInvitePayload {
  const JoinInvitePayload({
    required this.payloadVersion,
    required this.houseId,
    required this.hostNodeKey,
    required this.hostMagicDns,
    required this.joinCredential,
  });

  final int payloadVersion;
  final String houseId;
  final String hostNodeKey;
  final String hostMagicDns;
  final String joinCredential;

  factory JoinInvitePayload.fromJson(Map<String, dynamic> json) =>
      _$JoinInvitePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$JoinInvitePayloadToJson(this);
}
