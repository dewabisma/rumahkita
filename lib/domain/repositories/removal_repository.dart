import 'package:rumah/domain/entities/removal_proposal.dart';

abstract class RemovalRepository {
  Stream<List<RemovalProposal>> watchProposals(String houseId);

  Stream<RemovalProposal?> watchProposal(String proposalId);

  Stream<List<ProposalVote>> watchVotes(String proposalId);

  Future<RemovalMajoritySnapshot> majoritySnapshot(String proposalId);

  Future<RemovalProposal> proposeEviction({
    required String houseId,
    required String proposerMemberId,
    required String targetMemberId,
    String? justificationNotes,
  });

  Future<RemovalProposal> initiateSelfRemoval({
    required String houseId,
    required String targetMemberId,
  });

  Future<void> castVote({
    required String houseId,
    required String proposalId,
    required String voterMemberId,
    required bool voteYes,
  });

  Future<void> cancelProposal({
    required String houseId,
    required String proposalId,
    required String actorMemberId,
  });
}

class GuardianEvictionBlockedException implements Exception {
  GuardianEvictionBlockedException(this.targetMemberId);

  final String targetMemberId;

  @override
  String toString() =>
      'Cannot evict an active guardian during a live cycle.';
}

class RemovalProposalConflictException implements Exception {
  RemovalProposalConflictException(this.targetMemberId);

  final String targetMemberId;

  @override
  String toString() =>
      'A removal proposal for this member is already in progress.';
}
