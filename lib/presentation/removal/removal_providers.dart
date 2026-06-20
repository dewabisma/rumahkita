import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/removal_proposal.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';

final removalProposalsProvider =
    StreamProvider.family<List<RemovalProposal>, String>((ref, houseId) {
  return ref.watch(removalRepositoryProvider).watchProposals(houseId);
});

final removalProposalProvider =
    StreamProvider.family<RemovalProposal?, String>((ref, proposalId) {
  return ref.watch(removalRepositoryProvider).watchProposal(proposalId);
});

final proposalVotesProvider =
    StreamProvider.family<List<ProposalVote>, String>((ref, proposalId) {
  return ref.watch(removalRepositoryProvider).watchVotes(proposalId);
});

final removalMajorityProvider =
    FutureProvider.family<RemovalMajoritySnapshot, String>((ref, proposalId) {
  return ref.watch(removalRepositoryProvider).majoritySnapshot(proposalId);
});

final activeRemovalProposalsProvider =
    Provider.family<List<RemovalProposal>, String>((ref, houseId) {
  final proposals = ref.watch(removalProposalsProvider(houseId)).asData?.value;
  if (proposals == null) {
    return [];
  }
  return proposals
      .where(
        (p) =>
            p.status == ProposalStatus.proposed ||
            p.status == ProposalStatus.approved ||
            p.status == ProposalStatus.readyToExecute,
      )
      .toList();
});

final removalAuditProvider =
    StreamProvider.family<List<AuditLogEntry>, String>((ref, proposalId) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.auditLogAppendOnly)
    ..where((t) => t.taskId.equals(proposalId));
  return query.watch().map(
    (rows) => rows
        .map(
          (row) => AuditLogEntry(
            logId: row.logId,
            houseId: row.houseId,
            taskId: row.taskId,
            actorMemberId: row.actorMemberId,
            action: row.action,
            justificationNotes: row.justificationNotes,
            hlc: row.hlc,
          ),
        )
        .toList(),
  );
});

bool isMemberGuardianBlocked({
  required Housemate target,
  required Iterable<({String guardianId, String status})> cycles,
}) {
  return cycles.any(
    (c) =>
        (c.status == 'active' || c.status == 'handover') &&
        c.guardianId == target.memberId,
  );
}

String nicknameFor(
  String memberId,
  List<Housemate> mates,
) {
  return mates
          .where((m) => m.memberId == memberId)
          .map((m) => m.nickname)
          .firstOrNull ??
      memberId;
}

String statusLabel(ProposalStatus status) {
  return switch (status) {
    ProposalStatus.proposed => 'Proposed',
    ProposalStatus.approved => 'Approved',
    ProposalStatus.readyToExecute => 'Ready to execute',
    ProposalStatus.executed => 'Executed',
    ProposalStatus.cancelled => 'Cancelled',
    ProposalStatus.rejected => 'Rejected',
  };
}

bool isMemberInactive(MemberStatus status) =>
    status == MemberStatus.inactive || status == MemberStatus.evicted;
