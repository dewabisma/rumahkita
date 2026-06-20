import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/sync/state_machines/handover_step_machine.dart';

void main() {
  test('closeout to retro to ceremony_pending only', () {
    expect(
      HandoverStepMachine.canTransition(HandoverStep.closeout, HandoverStep.retro),
      isTrue,
    );
    expect(
      HandoverStepMachine.canTransition(HandoverStep.retro, HandoverStep.ceremonyPending),
      isTrue,
    );
    expect(
      HandoverStepMachine.canTransition(HandoverStep.ceremonyPending, HandoverStep.closeout),
      isFalse,
    );
  });

  test('null from only allows closeout', () {
    expect(
      HandoverStepMachine.canTransition(null, HandoverStep.closeout),
      isTrue,
    );
    expect(
      HandoverStepMachine.canTransition(null, HandoverStep.retro),
      isFalse,
    );
  });
}
