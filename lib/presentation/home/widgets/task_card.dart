import 'package:flutter/material.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.isClaimedByLocal,
    required this.onClaim,
    required this.onSubmit,
    this.readOnly = false,
  });

  final Task task;
  final bool isClaimedByLocal;
  final VoidCallback onClaim;
  final VoidCallback onSubmit;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final isUnclaimed = task.claimedByMemberIds.isEmpty;
    final isClaimedByOther = !isUnclaimed && !isClaimedByLocal;

    return Card(
      color: colors.activeSurface,
      margin: EdgeInsets.only(bottom: spacing.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(spacing.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: text.sectionTitle),
            if (task.description.isNotEmpty) ...[
              SizedBox(height: spacing.radiusSmall / 2),
              Text(
                task.description,
                style: text.body?.copyWith(color: colors.textSecondary),
              ),
            ],
            SizedBox(height: spacing.radiusSmall / 2),
            Text(
              'Worth ${task.negotiatedPoints} points',
              style: text.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            if (isClaimedByLocal) ...[
              SizedBox(height: spacing.radiusSmall),
              Text(
                'You claimed this chore — ready when you are.',
                style: text.bodySmall?.copyWith(color: colors.active),
              ),
            ],
            if (isClaimedByOther) ...[
              SizedBox(height: spacing.radiusSmall),
              Text(
                'Another housemate is working on this one.',
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
            if (!readOnly) ...[
              SizedBox(height: spacing.radiusSmall),
              Row(
                children: [
                  if (isUnclaimed)
                    FilledButton(
                      onPressed: onClaim,
                      child: const Text('Claim'),
                    )
                  else if (isClaimedByLocal)
                    FilledButton(
                      onPressed: onSubmit,
                      child: const Text('Submit for review'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
