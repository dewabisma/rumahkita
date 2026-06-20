import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/home/widgets/guardian_review_section.dart';
import 'package:rumah/presentation/home/widgets/task_list_section.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
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
    final activeCycle = houseId != null
        ? ref.watch(activeCycleProvider(houseId)).value
        : null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Home', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: houseId == null
            ? const Center(child: Text('No active house'))
            : ListView(
                padding: EdgeInsets.all(spacing.radiusCard),
                children: [
                  const ConnectionStatusHeader(),
                  SizedBox(height: spacing.radiusCard),
                  Text('Your house is active', style: text.headline),
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    'Claim chores, finish them, and let your guardian cheer you on.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  ),
                  if (activeCycle != null) ...[
                    SizedBox(height: spacing.radiusSmall),
                    Card(
                      color: colors.successSurface,
                      child: Padding(
                        padding: EdgeInsets.all(spacing.radiusCard),
                        child: Text(
                          'Guardian this cycle is keeping an eye on reviews.',
                          style: text.body,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: spacing.radiusCard),
                  TaskListSection(houseId: houseId),
                  SizedBox(height: spacing.radiusCard),
                  GuardianReviewSection(houseId: houseId),
                ],
              ),
      ),
    );
  }
}
