import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/removal/removal_audit_section.dart';
import 'package:rumah/presentation/removal/removal_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class RemovalProposalScreen extends ConsumerWidget {
  const RemovalProposalScreen({super.key, required this.proposalId});

  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final proposalAsync = ref.watch(removalProposalProvider(proposalId));
    final majorityAsync = ref.watch(removalMajorityProvider(proposalId));
    final votesAsync = ref.watch(proposalVotesProvider(proposalId));
    final localMember = ref.watch(localMemberProvider).asData?.value;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/house/roster');
            }
          },
        ),
        automaticallyImplyLeading: false,
        title: Text('Removal proposal', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: proposalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load proposal: $e')),
          data: (proposal) {
            if (proposal == null) {
              return const Center(child: Text('Proposal not found'));
            }
            final houseId = proposal.houseId;
            final mates =
                ref.watch(housematesProvider(houseId)).asData?.value ?? [];
            final targetName = nicknameFor(proposal.targetMemberId, mates);
            final isTarget = localMember?.memberId == proposal.targetMemberId;
            final isProposer =
                localMember?.memberId == proposal.proposerMemberId;
            final canVote = proposal.status == ProposalStatus.proposed &&
                localMember != null &&
                !isTarget;
            final canCancel = proposal.status == ProposalStatus.proposed &&
                isProposer &&
                localMember != null;

            return ListView(
              padding: EdgeInsets.all(spacing.radiusCard),
              children: [
                if (isTarget) ...[
                  Text(
                    'You are the subject of this proposal.',
                    style: text.body?.copyWith(color: colors.caution),
                  ),
                  SizedBox(height: spacing.radiusSmall),
                ],
                Text('Status: ${statusLabel(proposal.status)}', style: text.headline),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  'Target: $targetName',
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                Text(
                  'Type: ${proposal.type.name}',
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: spacing.radiusCard),
                majorityAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (snapshot) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vote threshold', style: text.sectionTitle),
                      SizedBox(height: spacing.radiusSmall),
                      Text(
                        'Yes: ${snapshot.yesCount} / ${snapshot.requiredYes} required '
                        '(${snapshot.eligibleVoters} eligible voters)',
                        style: text.body,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.radiusCard),
                votesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (votes) {
                    if (votes.isEmpty) {
                      return Text(
                        'No votes recorded.',
                        style: text.body?.copyWith(color: colors.textSecondary),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Votes', style: text.sectionTitle),
                        SizedBox(height: spacing.radiusSmall),
                        ...votes.map(
                          (v) => Text(
                            '${nicknameFor(v.voterMemberId, mates)}: '
                            '${v.voteCast ? 'yes' : 'no'}',
                            style: text.body?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (canVote) ...[
                  SizedBox(height: spacing.radiusCard),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _castVote(
                            ref,
                            houseId: houseId,
                            voterId: localMember.memberId,
                            voteYes: false,
                          ),
                          child: const Text('Vote no'),
                        ),
                      ),
                      SizedBox(width: spacing.radiusSmall),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _castVote(
                            ref,
                            houseId: houseId,
                            voterId: localMember.memberId,
                            voteYes: true,
                          ),
                          child: const Text('Vote yes'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (canCancel) ...[
                  SizedBox(height: spacing.radiusCard),
                  OutlinedButton(
                    onPressed: () => _cancelProposal(
                      ref,
                      context,
                      houseId: houseId,
                      actorId: localMember.memberId,
                    ),
                    child: const Text('Cancel proposal'),
                  ),
                ],
                SizedBox(height: spacing.radiusCard),
                RemovalAuditSection(proposalId: proposalId),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _castVote(
    WidgetRef ref, {
    required String houseId,
    required String voterId,
    required bool voteYes,
  }) async {
    await ref.read(removalRepositoryProvider).castVote(
          houseId: houseId,
          proposalId: proposalId,
          voterMemberId: voterId,
          voteYes: voteYes,
        );
  }

  Future<void> _cancelProposal(
    WidgetRef ref,
    BuildContext context, {
    required String houseId,
    required String actorId,
  }) async {
    await ref.read(removalRepositoryProvider).cancelProposal(
          houseId: houseId,
          proposalId: proposalId,
          actorMemberId: actorId,
        );
    if (context.mounted && context.canPop()) {
      context.pop();
    }
  }
}
