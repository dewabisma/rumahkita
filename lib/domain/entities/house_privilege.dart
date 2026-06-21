import 'package:rumah/domain/enums/privilege_status.dart';
import 'package:rumah/domain/enums/privilege_usage_mode.dart';

class HousePrivilege {
  const HousePrivilege({
    required this.privilegeId,
    required this.houseId,
    required this.cycleId,
    required this.name,
    required this.description,
    required this.pointCost,
    required this.status,
    required this.usageMode,
    required this.updatedAtHlc,
  });

  final String privilegeId;
  final String houseId;
  final String cycleId;
  final String name;
  final String description;
  final int pointCost;
  final PrivilegeStatus status;
  final PrivilegeUsageMode usageMode;
  final List<int> updatedAtHlc;

  bool get isArchived => status == PrivilegeStatus.archived;
}
