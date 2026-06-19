import 'package:rumah/domain/enums/member_status.dart';

class MemberStatusMachine {
  MemberStatusMachine._();

  static bool canTransition(MemberStatus? from, MemberStatus to) {
    if (from == null) {
      return to == MemberStatus.active;
    }
    if (from == MemberStatus.evicted) {
      return false;
    }
    switch (from) {
      case MemberStatus.active:
        return to == MemberStatus.inactive || to == MemberStatus.evicted;
      case MemberStatus.inactive:
        return to == MemberStatus.evicted;
      case MemberStatus.evicted:
        return false;
    }
  }

  static bool isExecutionTransition(MemberStatus from, MemberStatus to) {
    return to == MemberStatus.evicted;
  }
}
