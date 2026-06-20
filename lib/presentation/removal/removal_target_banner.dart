import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/removal/removal_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

/// Neutral banner when the local member is the target of an active removal.
class RemovalTargetBanner extends ConsumerWidget {
  const RemovalTargetBanner({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final localMember = ref.watch(localMemberProvider).asData?.value;
    if (localMember == null) {
      return const SizedBox.shrink();
    }

    final proposal = ref
        .watch(activeRemovalProposalsProvider(houseId))
        .where((p) => p.targetMemberId == localMember.memberId)
        .firstOrNull;
    if (proposal == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.radiusCard),
      child: Card(
        color: colors.caution.withValues(alpha: 0.12),
        child: Padding(
          padding: EdgeInsets.all(spacing.radiusCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'A removal proposal names you as the subject.',
                style: text.body?.copyWith(color: colors.textPrimary),
              ),
              SizedBox(height: spacing.radiusSmall),
              Text(
                'Status: ${statusLabel(proposal.status)}. '
                'You may view the proposal and audit record; voting is limited to other members.',
                style: text.caption?.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.radiusSmall),
              OutlinedButton(
                onPressed: () => context.push('/removal/${proposal.proposalId}'),
                child: const Text('View proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
