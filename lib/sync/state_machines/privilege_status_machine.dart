import 'package:rumah/domain/enums/privilege_status.dart';

class PrivilegeStatusMachine {
  PrivilegeStatusMachine._();

  static bool canTransition(PrivilegeStatus? from, PrivilegeStatus to) {
    if (from == null) {
      return to == PrivilegeStatus.active;
    }
    switch (from) {
      case PrivilegeStatus.active:
        return to == PrivilegeStatus.archived;
      case PrivilegeStatus.archived:
        return false;
    }
  }
}
