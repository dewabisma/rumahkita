import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/home/widgets/current_guardian_banner.dart';
import 'package:rumah/presentation/home/widgets/guardian_dashboard_section.dart';
import 'package:rumah/presentation/home/widgets/member_privileges_section.dart';
import 'package:rumah/presentation/home/widgets/privilege_notification_listener.dart';
import 'package:rumah/presentation/home/widgets/task_list_section.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/removal/removal_target_banner.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final houseId = ref.watch(activeHouseIdProvider).value;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Home', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: houseId == null
            ? const Center(child: Text('No active house'))
            : PrivilegeNotificationListener(
                houseId: houseId,
                child: ListView(
                  padding: EdgeInsets.all(spacing.radiusCard),
                  children: [
                    const ConnectionStatusHeader(),
                    SizedBox(height: spacing.radiusCard),
                    RemovalTargetBanner(houseId: houseId),
                    Text('Your house is active', style: text.headline),
                    SizedBox(height: spacing.radiusSmall),
                    Text(
                      'Claim chores, finish them, and let your guardian cheer you on.',
                      style: text.body?.copyWith(color: colors.textSecondary),
                    ),
                    SizedBox(height: spacing.radiusSmall),
                    CurrentGuardianBanner(houseId: houseId),
                    SizedBox(height: spacing.radiusCard),
                    MemberPrivilegesSection(houseId: houseId),
                    SizedBox(height: spacing.radiusCard),
                    TaskListSection(houseId: houseId),
                    SizedBox(height: spacing.radiusCard),
                    GuardianDashboardSection(houseId: houseId),
                    SizedBox(height: spacing.radiusCard),
                    Text('Household', style: text.sectionTitle),
                    SizedBox(height: spacing.radiusSmall),
                    OutlinedButton(
                      onPressed: () => context.push('/house/roster'),
                      child: const Text('View member roster'),
                    ),
                    if (ref.watch(isHouseCreatorProvider).value ?? false) ...[
                      SizedBox(height: spacing.radiusSmall),
                      OutlinedButton(
                        onPressed: () => context.push('/house/settings'),
                        child: const Text('House settings'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
