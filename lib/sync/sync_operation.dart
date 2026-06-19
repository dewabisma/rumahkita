import 'package:json_annotation/json_annotation.dart';

part 'sync_operation.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SyncOperation {
  const SyncOperation({
    required this.opId,
    required this.opType,
    required this.houseId,
    required this.originDeviceId,
    required this.hlc,
    this.actorMemberId,
    required this.payload,
  });

  final String opId;
  final String opType;
  final String houseId;
  final String originDeviceId;
  final String hlc;
  final String? actorMemberId;
  final Map<String, dynamic> payload;

  factory SyncOperation.fromJson(Map<String, dynamic> json) =>
      _$SyncOperationFromJson(json);

  Map<String, dynamic> toJson() => _$SyncOperationToJson(this);
}
