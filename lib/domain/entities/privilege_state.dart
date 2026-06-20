/// Computed privilege tier state for a member at a given score.
class PrivilegeState {
  const PrivilegeState({
    required this.templateId,
    required this.name,
    required this.isActive,
    required this.isPenalty,
  });

  final String templateId;
  final String name;
  final bool isActive;
  final bool isPenalty;
}
