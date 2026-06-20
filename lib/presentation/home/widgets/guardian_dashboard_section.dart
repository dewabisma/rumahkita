import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/presentation/home/guardian_providers.dart';
import 'package:rumah/presentation/home/widgets/reject_notes_dialog.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class GuardianDashboardSection extends ConsumerWidget {
  const GuardianDashboardSection({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuardian =
        ref.watch(isLocalGuardianProvider(houseId)).value ?? false;
    if (!isGuardian) {
      return const SizedBox.shrink();
    }

    final text = context.themeText;
    final spacing = context.themeSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Guardian dashboard', style: text.sectionTitle),
        SizedBox(height: spacing.radiusSmall),
        _PendingReviewPanel(houseId: houseId),
        SizedBox(height: spacing.radiusCard),
        _HouseScoreboardPanel(houseId: houseId),
        SizedBox(height: spacing.radiusCard),
        _InProgressTasksPanel(houseId: houseId),
      ],
    );
  }
}

class _PendingReviewPanel extends ConsumerWidget {
  const _PendingReviewPanel({required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final pendingAsync = ref.watch(guardianPendingReviewProvider(houseId));
    final localMember = ref.watch(localMemberProvider).asData?.value;

    return pendingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Could not load review queue', style: text.body),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Card(
            color: colors.surfaceCard,
            child: Padding(
              padding: EdgeInsets.all(spacing.radiusCard),
              child: Text(
                'Nothing waiting for your review right now.',
                style: text.body?.copyWith(color: colors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Awaiting your review', style: text.sectionTitle),
            SizedBox(height: spacing.radiusSmall),
            ...tasks.map(
              (task) => _ReviewCard(
                task: task,
                colors: colors,
                text: text,
                spacing: spacing,
                onApprove: () => _approve(context, ref, task, localMember?.memberId),
                onReject: () =>
                    _reject(context, ref, task, localMember?.memberId),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String? memberId,
  ) async {
    if (memberId == null) {
      return;
    }
    try {
      await ref.read(taskRepositoryProvider).approve(
            houseId: houseId,
            taskId: task.taskId,
            guardianMemberId: memberId,
          );
    } on TaskOperationException {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Could not approve this chore right now — try again in a moment.',
        );
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String? memberId,
  ) async {
    if (memberId == null) {
      return;
    }
    final notes = await RejectNotesDialog.show(context);
    if (!context.mounted) {
      return;
    }
    try {
      await ref.read(taskRepositoryProvider).reject(
            houseId: houseId,
            taskId: task.taskId,
            guardianMemberId: memberId,
            justificationNotes: notes,
          );
    } on TaskOperationException {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Could not send this chore back right now — try again in a moment.',
        );
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.task,
    required this.colors,
    required this.text,
    required this.spacing,
    required this.onApprove,
    required this.onReject,
  });

  final Task task;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colors.surfaceCard,
      margin: EdgeInsets.only(bottom: spacing.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(spacing.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: text.sectionTitle),
            SizedBox(height: spacing.radiusSmall / 2),
            Text(
              '${task.negotiatedPoints} points · claimed by ${task.claimedByMemberIds.length} housemate(s)',
              style: text.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.radiusSmall),
            Row(
              children: [
                FilledButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
                SizedBox(width: spacing.radiusSmall),
                OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Send back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseScoreboardPanel extends ConsumerWidget {
  const _HouseScoreboardPanel({required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final scoreboardAsync = ref.watch(houseScoreboardProvider(houseId));

    return scoreboardAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (mates) {
        return Card(
          color: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('House scoreboard', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                if (mates.isEmpty)
                  Text(
                    'No active housemates yet.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  )
                else
                  ...mates.map(
                    (mate) => _ScoreboardRow(
                      mate: mate,
                      colors: colors,
                      text: text,
                      spacing: spacing,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreboardRow extends StatelessWidget {
  const _ScoreboardRow({
    required this.mate,
    required this.colors,
    required this.text,
    required this.spacing,
  });

  final Housemate mate;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.radiusSmall / 2),
      child: Row(
        children: [
          Expanded(child: Text(mate.nickname, style: text.body)),
          Text(
            '${mate.lifetimeScore} pts',
            style: text.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InProgressTasksPanel extends ConsumerWidget {
  const _InProgressTasksPanel({required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final inProgressAsync = ref.watch(guardianInProgressTasksProvider(houseId));

    return inProgressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (tasks) {
        return Card(
          color: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('In progress', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                if (tasks.isEmpty)
                  Text(
                    'No chores being worked on right now.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  )
                else
                  ...tasks.map(
                    (task) => Padding(
                      padding: EdgeInsets.only(bottom: spacing.radiusSmall / 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(task.title, style: text.body),
                          ),
                          Text(
                            '${task.claimedByMemberIds.length} working',
                            style: text.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
