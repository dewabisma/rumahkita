import 'package:rumah/domain/enums/cycle_status.dart';

class CycleStatusMachine {
  CycleStatusMachine._();

  static bool canTransition(CycleStatus? from, CycleStatus to) {
    if (from == null) {
      return to == CycleStatus.drafting;
    }
    switch (from) {
      case CycleStatus.drafting:
        return to == CycleStatus.active;
      case CycleStatus.active:
        return to == CycleStatus.handover;
      case CycleStatus.handover:
        return to == CycleStatus.completed;
      case CycleStatus.completed:
        return false;
    }
  }
}
