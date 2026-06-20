import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/handover_step.dart';

class CeremonySignoff {
  const CeremonySignoff({
    required this.accepted,
    required this.hlc,
    this.deviceId,
  });

  final bool accepted;
  final String hlc;
  final String? deviceId;
}

class Cycle {
  const Cycle({
    required this.cycleId,
    required this.houseId,
    required this.activeGuardianMemberId,
    required this.status,
    required this.ceremonySignoffs,
    required this.rulesVersionAtSignoff,
    required this.updatedAtHlc,
    this.startedAtHlc,
    this.endsAtHlc,
    this.cycleStartScoresJson = '{}',
    this.handoverStep,
  });

  final String cycleId;
  final String houseId;
  final String activeGuardianMemberId;
  final CycleStatus status;
  final Map<String, CeremonySignoff> ceremonySignoffs;
  final int rulesVersionAtSignoff;
  final List<int> updatedAtHlc;
  final List<int>? startedAtHlc;
  final List<int>? endsAtHlc;
  final String cycleStartScoresJson;
  final HandoverStep? handoverStep;

  bool get isLive =>
      status == CycleStatus.active || status == CycleStatus.handover;
}
