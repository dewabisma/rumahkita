import 'package:rumah/domain/entities/privilege_state.dart';

/// Stub enforcement hooks for privilege-gated actions (v1).
class PrivilegeGates {
  PrivilegeGates._();

  static bool _hasActiveRedemption(
    List<PrivilegeState> states,
    String nameFragment,
  ) {
    return states.any(
      (s) =>
          s.isActive &&
          s.name.toLowerCase().contains(nameFragment.toLowerCase()),
    );
  }

  static bool canUseParkingSlot(List<PrivilegeState> states) =>
      _hasActiveRedemption(states, 'parking');

  static bool canUseChorePass(List<PrivilegeState> states) =>
      _hasActiveRedemption(states, 'chore');

  static bool isCleaningExempt(List<PrivilegeState> states) =>
      _hasActiveRedemption(states, 'cleaning');
}
