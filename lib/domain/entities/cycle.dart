import 'package:rumah/domain/enums/cycle_status.dart';

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
  });

  final String cycleId;
  final String houseId;
  final String activeGuardianMemberId;
  final CycleStatus status;
  final Map<String, CeremonySignoff> ceremonySignoffs;
  final int rulesVersionAtSignoff;
  final List<int> updatedAtHlc;
}
