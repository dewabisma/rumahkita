import 'package:rumah/domain/enums/handover_step.dart';

class HandoverStepMachine {
  HandoverStepMachine._();

  static bool canTransition(HandoverStep? from, HandoverStep to) {
    if (from == null) {
      return to == HandoverStep.closeout;
    }
    switch (from) {
      case HandoverStep.closeout:
        return to == HandoverStep.retro;
      case HandoverStep.retro:
        return to == HandoverStep.ceremonyPending;
      case HandoverStep.ceremonyPending:
        return false;
    }
  }
}
