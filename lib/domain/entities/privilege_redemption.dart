import 'package:rumah/domain/enums/redemption_status.dart';

class PrivilegeRedemption {
  const PrivilegeRedemption({
    required this.redemptionId,
    required this.houseId,
    required this.memberId,
    required this.privilegeId,
    required this.cycleId,
    required this.pointCost,
    required this.status,
    required this.hlc,
  });

  final String redemptionId;
  final String houseId;
  final String memberId;
  final String privilegeId;
  final String cycleId;
  final int pointCost;
  final RedemptionStatus status;
  final List<int> hlc;

  bool get isActive => status == RedemptionStatus.active;
}
