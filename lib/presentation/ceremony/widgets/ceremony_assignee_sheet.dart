import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

/// Returns selected member id, or empty string for unassigned.
Future<String?> showCeremonyAssigneeSheet(
  BuildContext context, {
  required List<Housemate> housemates,
  required String? currentMemberId,
}) {
  final activeMates = housemates
      .where((m) => m.memberStatus == MemberStatus.active)
      .toList()
    ..sort((a, b) => a.nickname.compareTo(b.nickname));

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final colors = sheetContext.themeColors;
      final text = sheetContext.themeText;
      final spacing = sheetContext.themeSpacing;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.radiusCard,
          0,
          spacing.radiusCard,
          spacing.radiusCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Assign to', style: text.sectionTitle),
            SizedBox(height: spacing.radiusSmall),
            Text(
              'Pick who will take this chore when the cycle starts.',
              style: text.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.radiusCard),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.person_off_outlined, color: colors.textMuted),
              title: const Text('Unassigned'),
              trailing: currentMemberId == null || currentMemberId.isEmpty
                  ? Icon(Icons.check, color: colors.success)
                  : null,
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            ...activeMates.map(
              (mate) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_outline, color: colors.textPrimary),
                title: Text(mate.nickname),
                trailing: currentMemberId == mate.memberId
                    ? Icon(Icons.check, color: colors.success)
                    : null,
                onTap: () => Navigator.pop(sheetContext, mate.memberId),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String assigneeLabel({
  required String? assignedToMemberId,
  required List<Housemate> housemates,
}) {
  if (assignedToMemberId == null || assignedToMemberId.isEmpty) {
    return 'Unassigned';
  }
  final mate = housemates
      .where((m) => m.memberId == assignedToMemberId)
      .firstOrNull;
  return mate?.nickname ?? 'Housemate';
}
