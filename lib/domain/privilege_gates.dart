import 'package:rumah/domain/entities/privilege_state.dart';

/// Stub enforcement hooks for privilege-gated actions (slice 1).
class PrivilegeGates {
  PrivilegeGates._();

  static bool _isActive(List<PrivilegeState> states, String templateId) {
    return states.any((s) => s.templateId == templateId && s.isActive);
  }

  static bool canUseParkingSlot(List<PrivilegeState> states) =>
      _isActive(states, 'parking');

  static bool canUseChorePass(List<PrivilegeState> states) =>
      _isActive(states, 'chore_pass');

  static bool isCleaningExempt(List<PrivilegeState> states) =>
      _isActive(states, 'cleaning_exempt');

  static bool hasChoreSlotRestriction(List<PrivilegeState> states) =>
      _isActive(states, 'slot_restriction');
}
