import 'package:json_annotation/json_annotation.dart';
import 'package:rumah/sync/sync_operation.dart';

part 'sync_envelope.g.dart';

const int syncProtocolVersion = 1;

enum RejectReason {
  invalidProtocol,
  houseMismatch,
  peerNotAllowlisted,
  evictedSender,
  evictedActor,
  idempotencyConflict,
  mergeRejected,
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SyncEnvelope {
  const SyncEnvelope({
    required this.protocolVersion,
    required this.envelopeId,
    required this.houseId,
    required this.senderDeviceId,
    required this.senderTailscaleNodeKey,
    this.senderMemberId,
    required this.hlc,
    required this.ops,
    this.vectorClock,
    this.joinCredential,
  });

  final int protocolVersion;
  final String envelopeId;
  final String houseId;
  final String senderDeviceId;
  final String senderTailscaleNodeKey;
  final String? senderMemberId;
  final String hlc;
  final List<SyncOperation> ops;
  final Map<String, int>? vectorClock;
  final String? joinCredential;

  factory SyncEnvelope.fromJson(Map<String, dynamic> json) =>
      _$SyncEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$SyncEnvelopeToJson(this);
}

class EnvelopeValidationResult {
  const EnvelopeValidationResult.valid() : isValid = true, reason = null;

  const EnvelopeValidationResult.invalid(this.reason) : isValid = false;

  final bool isValid;
  final RejectReason? reason;
}

class SyncEnvelopeValidator {
  static EnvelopeValidationResult validateProtocol(SyncEnvelope envelope) {
    if (envelope.protocolVersion != syncProtocolVersion) {
      return const EnvelopeValidationResult.invalid(
        RejectReason.invalidProtocol,
      );
    }
    return const EnvelopeValidationResult.valid();
  }

  static EnvelopeValidationResult validateHouse(
    SyncEnvelope envelope,
    String activeHouseId,
  ) {
    if (envelope.houseId != activeHouseId) {
      return const EnvelopeValidationResult.invalid(RejectReason.houseMismatch);
    }
    for (final op in envelope.ops) {
      if (op.houseId != activeHouseId) {
        return const EnvelopeValidationResult.invalid(
          RejectReason.houseMismatch,
        );
      }
    }
    return const EnvelopeValidationResult.valid();
  }
}
