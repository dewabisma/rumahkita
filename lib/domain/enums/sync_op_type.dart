/// Wire op types understood by [MergeEngine].
enum SyncOpType {
  houseCreate('house_create'),
  housemateCreate('housemate_create'),
  houseDisplayNameUpdate('house_display_name_update'),
  houseRulesVersionUpdate('house_rules_version_update'),
  housePrivilegeTemplatesUpdate('house_privilege_templates_update'),
  housemateNicknameUpdate('housemate_nickname_update'),
  memberStatusTransition('member_status_transition'),
  rotationAssignment('rotation_assignment'),
  scoreEventAppend('score_event_append'),
  proposalCreate('proposal_create'),
  proposalStatusTransition('proposal_status_transition'),
  voteCast('vote_cast'),
  cycleCreate('cycle_create'),
  cycleStatusTransition('cycle_status_transition'),
  cycleGuardianUpdate('cycle_guardian_update'),
  cycleSignoffSet('cycle_signoff_set'),
  taskCreate('task_create'),
  taskFieldUpdate('task_field_update'),
  taskClaim('task_claim'),
  auditLogAppend('audit_log_append');

  const SyncOpType(this.wireValue);

  final String wireValue;

  static SyncOpType fromWire(String value) =>
      SyncOpType.values.firstWhere((e) => e.wireValue == value);
}
