import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/presentation/home/guardian_providers.dart';
import 'package:rumah/presentation/home/widgets/guardian_dashboard_section.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class HandoverScreen extends ConsumerWidget {
  const HandoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final houseId = ref.watch(activeHouseIdProvider).value;

    if (houseId == null) {
      return const Scaffold(body: Center(child: Text('No active house')));
    }

    final handoverAsync = ref.watch(handoverCycleProvider(houseId));
    final phaseAsync = ref.watch(houseRouterPhaseProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        automaticallyImplyLeading: false,
        title: Text('Cycle handover', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: handoverAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load handover: $e')),
          data: (handover) {
            if (handover == null) {
              return const Center(child: Text('No handover cycle'));
            }
            final step = handover.handoverStep ?? HandoverStep.closeout;
            final phase = phaseAsync.value?.phase;

            return ListView(
              padding: EdgeInsets.all(spacing.radiusCard),
              children: [
                const ConnectionStatusHeader(),
                SizedBox(height: spacing.radiusCard),
                Text('Wrapping up this cycle', style: text.headline),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  _stepDescription(step),
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: spacing.radiusCard),
                if (step == HandoverStep.closeout) ...[
                  GuardianDashboardSection(houseId: houseId),
                  SizedBox(height: spacing.radiusCard),
                  _AdvanceToRetroButton(houseId: houseId, cycleId: handover.cycleId),
                ],
                if (step == HandoverStep.retro) ...[
                  _RetroSection(houseId: houseId),
                  SizedBox(height: spacing.radiusCard),
                  _StartCeremonyButton(
                    houseId: houseId,
                    handoverCycleId: handover.cycleId,
                  ),
                ],
                if (phase == HouseRedirectPhase.handoverCeremonyPending)
                  Text(
                    'Head to ceremony to sign off on the next cycle.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _stepDescription(HandoverStep step) {
    switch (step) {
      case HandoverStep.closeout:
        return 'Review any chores still waiting for approval before looking back on the week.';
      case HandoverStep.retro:
        return 'Celebrate wins, notice patterns, then start the next cycle ceremony.';
      case HandoverStep.ceremonyPending:
        return 'The next cycle is ready for everyone to accept.';
    }
  }
}

class _AdvanceToRetroButton extends ConsumerWidget {
  const _AdvanceToRetroButton({
    required this.houseId,
    required this.cycleId,
  });

  final String houseId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(guardianPendingReviewProvider(houseId)).value ?? [];
    final isGuardian = ref.watch(isHandoverGuardianProvider(houseId)).value ?? false;
    final localMember = ref.watch(localMemberProvider).asData?.value;

    if (!isGuardian) {
      return const SizedBox.shrink();
    }

    return FilledButton(
      onPressed: pending.isNotEmpty || localMember == null
          ? null
          : () async {
              await ref.read(ceremonyRepositoryProvider).advanceHandoverStep(
                    houseId: houseId,
                    cycleId: cycleId,
                    actorMemberId: localMember.memberId,
                    from: HandoverStep.closeout.wireValue,
                    to: HandoverStep.retro.wireValue,
                  );
            },
      child: Text(
        pending.isNotEmpty
            ? 'Finish reviews first'
            : 'Continue to retrospective',
      ),
    );
  }
}

class _StartCeremonyButton extends ConsumerWidget {
  const _StartCeremonyButton({
    required this.houseId,
    required this.handoverCycleId,
  });

  final String houseId;
  final String handoverCycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuardian = ref.watch(isHandoverGuardianProvider(houseId)).value ?? false;
    final localMember = ref.watch(localMemberProvider).asData?.value;

    if (!isGuardian) {
      return const SizedBox.shrink();
    }

    return FilledButton(
      onPressed: localMember == null
          ? null
          : () async {
              await ref.read(ceremonyRepositoryProvider).startNextCycleCeremony(
                    houseId: houseId,
                    handoverCycleId: handoverCycleId,
                    actorMemberId: localMember.memberId,
                  );
              if (context.mounted) {
                context.push('/ceremony');
              }
            },
      child: const Text('Start next cycle ceremony'),
    );
  }
}

class _RetroSection extends ConsumerWidget {
  const _RetroSection({required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final retroAsync = ref.watch(cycleRetrospectiveProvider(houseId));
    final matesAsync = ref.watch(housematesProvider(houseId));

    return retroAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) {
        final retro = data.retrospective;
        if (retro == null) {
          return const SizedBox.shrink();
        }
        final nicknames = {
          for (final m in matesAsync.asData?.value ?? [])
            m.memberId: m.nickname,
        };

        return Card(
          color: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Retrospective', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                if (retro.mvpMemberId != null)
                  _RetroRow(
                    label: 'MVP',
                    value: nicknames[retro.mvpMemberId] ?? retro.mvpMemberId!,
                    text: text,
                  ),
                if (retro.mostImprovedMemberId != null)
                  _RetroRow(
                    label: 'Most improved',
                    value: nicknames[retro.mostImprovedMemberId] ??
                        retro.mostImprovedMemberId!,
                    text: text,
                  ),
                if (retro.choreDodgerMemberId != null)
                  _RetroRow(
                    label: 'Chore dodger',
                    value: nicknames[retro.choreDodgerMemberId] ??
                        retro.choreDodgerMemberId!,
                    text: text,
                  ),
                if (retro.neglectedChoreTitles.isNotEmpty) ...[
                  SizedBox(height: spacing.radiusSmall),
                  Text('Neglected chores', style: text.bodySmall),
                  ...retro.neglectedChoreTitles.map(
                    (title) => Text('· $title', style: text.body),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RetroRow extends StatelessWidget {
  const _RetroRow({
    required this.label,
    required this.value,
    required this.text,
  });

  final String label;
  final String value;
  final AppTextTheme text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: text.bodySmall),
          Text(value, style: text.body),
        ],
      ),
    );
  }
}
