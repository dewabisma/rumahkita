import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/presentation/home/home_providers.dart';
import 'package:rumah/presentation/home/widgets/task_card.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class TaskListSection extends ConsumerWidget {
  const TaskListSection({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final openTasksAsync = ref.watch(openTasksProvider(houseId));
    final pendingReviewAsync = ref.watch(localPendingReviewTasksProvider(houseId));
    final localMember = ref.watch(localMemberProvider).asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pendingReviewAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text(
            'Could not load your submitted chores',
            style: text.body,
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Your chores awaiting review', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                ...tasks.map(
                  (task) => TaskCard(
                    task: task,
                    isClaimedByLocal: true,
                    readOnly: true,
                    onClaim: () {},
                    onSubmit: () {},
                  ),
                ),
                SizedBox(height: spacing.radiusCard),
              ],
            );
          },
        ),
        openTasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Could not load chores', style: text.body),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Card(
                color: colors.surfaceCard,
                child: Padding(
                  padding: EdgeInsets.all(spacing.radiusCard),
                  child: Text(
                    'All caught up for now — no open chores waiting.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Open chores', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                ...tasks.map(
                  (task) => TaskCard(
                    task: task,
                    isClaimedByLocal:
                        localMember != null &&
                        task.claimedByMemberIds.contains(localMember.memberId),
                    onClaim: () => _claim(context, ref, task, localMember?.memberId),
                    onSubmit: () =>
                        _submit(context, ref, task, localMember?.memberId),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _claim(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String? memberId,
  ) async {
    if (memberId == null) {
      return;
    }
    try {
      await ref.read(taskRepositoryProvider).claim(
            houseId: houseId,
            taskId: task.taskId,
            actorMemberId: memberId,
          );
    } on TaskOperationException {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Could not claim this chore right now — try again in a moment.',
        );
      }
    }
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String? memberId,
  ) async {
    if (memberId == null) {
      return;
    }
    try {
      await ref.read(taskRepositoryProvider).submitForReview(
            houseId: houseId,
            taskId: task.taskId,
            actorMemberId: memberId,
          );
    } on TaskOperationException {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Could not submit this chore for review — try again in a moment.',
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
