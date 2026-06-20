import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/onboarding/widgets/member_roster_list.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final houseIdAsync = ref.watch(activeHouseIdProvider);

    return OnboardingScaffold(
      title: 'House lobby',
      subtitle: 'Everyone who has joined so far.',
      showBack: true,
      header: const ConnectionStatusHeader(),
      child: houseIdAsync.when(
        data: (houseId) {
          if (houseId == null) {
            return const Center(child: Text('No active house yet'));
          }
          final housematesAsync = ref.watch(housematesProvider(houseId));
          final draftingCycle =
              ref.watch(draftingCycleProvider(houseId)).value;
          final liveCycleCtx = ref.watch(houseRouterPhaseProvider).value;
          final showLateJoinInfo = liveCycleCtx != null &&
              (liveCycleCtx.activeCycle != null ||
                  liveCycleCtx.handoverCycle != null);
          return housematesAsync.when(
            data: (mates) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showLateJoinInfo) ...[
                  Card(
                    color: colors.surfaceElevated,
                    child: Padding(
                      padding: EdgeInsets.all(spacing.radiusCard),
                      child: Text(
                        'This house has an active cycle. You inherit the current '
                        'rules, are appended to the end of the rotation queue, '
                        'and do not need to participate in ceremony sign-off.',
                        style: text.body?.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.radiusSmall),
                ],
                Expanded(child: MemberRosterList(members: mates)),
                SizedBox(height: spacing.radiusCard),
                if (draftingCycle != null) ...[
                  Card(
                    color: colors.activeSurface,
                    child: Padding(
                      padding: EdgeInsets.all(spacing.radiusCard),
                      child: Text(
                        'Ceremony in progress — review and accept house rules together.',
                        style: text.body?.copyWith(color: colors.active),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.radiusSmall),
                  FilledButton(
                    onPressed: () => context.push('/ceremony'),
                    child: const Text('Continue to ceremony'),
                  ),
                ] else
                  FilledButton(
                    onPressed: () => _startCeremony(ref, houseId, context),
                    child: const Text('Start Ceremony'),
                  ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _startCeremony(
    WidgetRef ref,
    String houseId,
    BuildContext context,
  ) async {
    await ref.read(ceremonyRepositoryProvider).startCeremony(houseId);
    if (!context.mounted) {
      return;
    }
    context.push('/ceremony');
  }
}
