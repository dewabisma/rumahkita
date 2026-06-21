import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/network_settings_sheet.dart';
import 'package:rumah/presentation/onboarding/widgets/nickname_edit_sheet.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

Future<void> showOnboardingSettingsActionSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final canDisband = await ref.read(canDisbandSoloHouseProvider.future);

  if (!context.mounted) {
    return;
  }

  final colors = context.themeColors;
  final text = context.themeText;
  final spacing = context.themeSpacing;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
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
            Text('Settings', style: text.sectionTitle),
            SizedBox(height: spacing.radiusCard),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.badge_outlined, color: colors.textPrimary),
              title: const Text('Edit nickname'),
              subtitle: Text(
                'Change how you appear to roommates',
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await showNicknameEditSheet(context);
              },
            ),
            SizedBox(height: spacing.radiusSmall),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.wifi, color: colors.textPrimary),
              title: const Text('Network settings'),
              subtitle: Text(
                'Auth key and admin API key',
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await showNetworkSettingsSheet(context);
              },
            ),
            if (canDisband) ...[
              SizedBox(height: spacing.radiusSmall),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.home_work_outlined, color: colors.caution),
                title: Text(
                  'Disband house',
                  style: text.body?.copyWith(color: colors.caution),
                ),
                subtitle: Text(
                  'Clear local house data and start over',
                  style: text.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _confirmDisbandHouse(context, ref);
                },
              ),
            ],
          ],
        ),
      );
    },
  );
}

Future<void> _confirmDisbandHouse(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Disband this house?'),
      content: const Text(
        'You are the only member left. This clears local house data on '
        'this device and returns you to the welcome screen.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Disband house'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }

  final disbanded =
      await ref.read(onboardingNotifierProvider.notifier).disbandSoloHouse();
  if (!context.mounted) {
    return;
  }
  if (!disbanded) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cannot disband while other members are still active'),
      ),
    );
  }
}
