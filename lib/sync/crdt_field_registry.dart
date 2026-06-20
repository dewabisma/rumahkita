enum CrdtKind {
  appendOnlyCreate,
  appendOnly,
  lwwRegister,
  orMapKeyedRegister,
  gSet,
  pnCounter,
  stateMachine,
  immutable,
  projected,
}

class FieldSpec {
  const FieldSpec({
    required this.kind,
    this.stateMachineId,
    this.orMapKeyPrefix,
  });

  final CrdtKind kind;
  final String? stateMachineId;
  final String? orMapKeyPrefix;
}

/// Central registry mapping `(table, column)` to merge strategy.
class CrdtFieldRegistry {
  CrdtFieldRegistry._();

  static final Map<String, FieldSpec> _registry = {
    'house_sync.house_id': const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'house_sync.display_name': const FieldSpec(kind: CrdtKind.lwwRegister),
    'house_sync.creator_member_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'house_sync.rules_version': const FieldSpec(kind: CrdtKind.lwwRegister),
    'house_sync.privilege_templates':
        const FieldSpec(kind: CrdtKind.lwwRegister),
    'house_sync.created_at_hlc':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'house_sync.updated_at_hlc': const FieldSpec(kind: CrdtKind.lwwRegister),
    'housemates_sync.member_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'housemates_sync.house_id': const FieldSpec(kind: CrdtKind.immutable),
    'housemates_sync.tailscale_user_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'housemates_sync.tailscale_node_key':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'housemates_sync.nickname': const FieldSpec(kind: CrdtKind.lwwRegister),
    'housemates_sync.lifetime_score':
        const FieldSpec(kind: CrdtKind.projected),
    'housemates_sync.rotation_order_index':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'housemates_sync.member_status': const FieldSpec(
      kind: CrdtKind.stateMachine,
      stateMachineId: 'member_status',
    ),
    'housemates_sync.evicted_at_hlc':
        const FieldSpec(kind: CrdtKind.appendOnly),
    'housemates_sync.updated_at_hlc':
        const FieldSpec(kind: CrdtKind.lwwRegister),
    'score_events.event_id': const FieldSpec(kind: CrdtKind.appendOnly),
    'score_events.house_id': const FieldSpec(kind: CrdtKind.immutable),
    'score_events.member_id': const FieldSpec(kind: CrdtKind.immutable),
    'score_events.delta': const FieldSpec(kind: CrdtKind.appendOnly),
    'score_events.reason_ref': const FieldSpec(kind: CrdtKind.appendOnly),
    'score_events.hlc': const FieldSpec(kind: CrdtKind.appendOnly),
    'score_events.actor_device_id':
        const FieldSpec(kind: CrdtKind.appendOnly),
    'removal_proposals_sync.proposal_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'removal_proposals_sync.house_id':
        const FieldSpec(kind: CrdtKind.immutable),
    'removal_proposals_sync.target_member_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'removal_proposals_sync.proposer_member_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'removal_proposals_sync.type':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'removal_proposals_sync.status': const FieldSpec(
      kind: CrdtKind.stateMachine,
      stateMachineId: 'proposal_status',
    ),
    'removal_proposals_sync.created_at_hlc':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'removal_proposals_sync.updated_at_hlc':
        const FieldSpec(kind: CrdtKind.appendOnly),
    'proposal_votes_sync.vote_id':
        const FieldSpec(kind: CrdtKind.appendOnly),
    'proposal_votes_sync.vote_cast': const FieldSpec(
      kind: CrdtKind.orMapKeyedRegister,
      orMapKeyPrefix: 'vote',
    ),
    'proposal_votes_sync.hlc': const FieldSpec(kind: CrdtKind.orMapKeyedRegister),
    'cycles_sync.cycle_id':
        const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'cycles_sync.status': const FieldSpec(
      kind: CrdtKind.stateMachine,
      stateMachineId: 'cycle_status',
    ),
    'cycles_sync.active_guardian_member_id':
        const FieldSpec(kind: CrdtKind.lwwRegister),
    'cycles_sync.ceremony_signoffs': const FieldSpec(
      kind: CrdtKind.orMapKeyedRegister,
      orMapKeyPrefix: 'signoff',
    ),
    'cycles_sync.rules_version_at_signoff':
        const FieldSpec(kind: CrdtKind.lwwRegister),
    'tasks_sync.task_id': const FieldSpec(kind: CrdtKind.appendOnlyCreate),
    'tasks_sync.title': const FieldSpec(kind: CrdtKind.lwwRegister),
    'tasks_sync.negotiated_points':
        const FieldSpec(kind: CrdtKind.lwwRegister),
    'tasks_sync.status': const FieldSpec(kind: CrdtKind.lwwRegister),
    'tasks_sync.claimed_by_member_ids':
        const FieldSpec(kind: CrdtKind.projected),
    'task_claim_events.event_id':
        const FieldSpec(kind: CrdtKind.appendOnly),
    'audit_log_append_only.log_id':
        const FieldSpec(kind: CrdtKind.appendOnly),
    'audit_log_append_only.house_id':
        const FieldSpec(kind: CrdtKind.immutable),
    'audit_log_append_only.task_id':
        const FieldSpec(kind: CrdtKind.immutable),
    'audit_log_append_only.actor_member_id':
        const FieldSpec(kind: CrdtKind.immutable),
    'audit_log_append_only.action':
        const FieldSpec(kind: CrdtKind.immutable),
    'audit_log_append_only.justification_notes':
        const FieldSpec(kind: CrdtKind.immutable),
    'audit_log_append_only.hlc':
        const FieldSpec(kind: CrdtKind.appendOnly),
  };

  static FieldSpec? lookup(String table, String column) =>
      _registry['$table.$column'];

  static FieldSpec require(String table, String column) {
    final spec = lookup(table, column);
    if (spec == null) {
      throw StateError('No CRDT spec for $table.$column');
    }
    return spec;
  }
}
