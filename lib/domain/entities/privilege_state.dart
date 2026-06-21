import 'package:rumah/domain/entities/house_privilege.dart';
import 'package:rumah/domain/entities/privilege_redemption.dart';
import 'package:rumah/domain/enums/privilege_usage_mode.dart';

/// Runtime privilege view for a member: owned redemption + catalog item.
class PrivilegeState {
  const PrivilegeState({
    required this.privilege,
    required this.redemption,
  });

  final HousePrivilege privilege;
  final PrivilegeRedemption redemption;

  String get privilegeId => privilege.privilegeId;
  String get name => privilege.name;
  bool get isOneShot => privilege.usageMode == PrivilegeUsageMode.oneShot;
  bool get isActive => redemption.isActive;
}
