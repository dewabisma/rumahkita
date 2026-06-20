import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
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
        child: Padding(
          padding: EdgeInsets.all(spacing.radiusCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ConnectionStatusHeader(),
              SizedBox(height: spacing.radiusCard),
              Text('Your house is active', style: text.headline),
              const SizedBox(height: 8),
              Text(
                'Ceremony complete — the living cycle has begun.',
                style: text.body?.copyWith(color: colors.textSecondary),
              ),
              if (activeCycle != null) ...[
                SizedBox(height: spacing.radiusCard),
                Card(
                  color: colors.successSurface,
                  child: Padding(
                    padding: EdgeInsets.all(spacing.radiusCard),
                    child: Text(
                      'Guardian this cycle: ${activeCycle.activeGuardianMemberId.substring(0, 8)}…',
                      style: text.body,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'Phase 3 gameplay screens coming soon.',
                style: text.caption?.copyWith(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
