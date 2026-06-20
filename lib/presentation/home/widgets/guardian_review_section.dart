import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/presentation/home/home_providers.dart';
import 'package:rumah/presentation/home/widgets/reject_notes_dialog.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class GuardianReviewSection extends ConsumerWidget {
  const GuardianReviewSection({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final isGuardian =
        ref.watch(isLocalGuardianProvider(houseId)).value ?? false;
    if (!isGuardian) {
      return const SizedBox.shrink();
    }

    final pendingAsync = ref.watch(pendingReviewTasksProvider(houseId));
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
