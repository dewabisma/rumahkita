String removalApprovedOpId(String proposalId) => 'removal-approved-$proposalId';

String removalReadyOpId(String proposalId) => 'removal-ready-$proposalId';

String removalRejectedOpId(String proposalId) => 'removal-rejected-$proposalId';

String removalExecutedOpId(String proposalId) => 'removal-executed-$proposalId';

String removalEvictMemberOpId(String proposalId) => 'removal-evict-$proposalId';

String removalAuditOpId(String logId) => 'removal-audit-$logId';

String removalPendingCreatorOpId(String proposalId) =>
    'removal-pending-creator-$proposalId';

String removalProposalCreatedAuditOpId(String proposalId) =>
    'removal-audit-created-$proposalId';

String removalVoteCastAuditOpId(String proposalId, String voterMemberId) =>
    'removal-audit-vote-$proposalId-$voterMemberId';

String removalStatusAuditOpId(String proposalId, String status) =>
    'removal-audit-status-$proposalId-$status';
