import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/removal/removal_providers.dart';
import 'package:rumah/presentation/removal/removal_target_banner.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class MemberRosterScreen extends ConsumerWidget {
  const MemberRosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final houseId = ref.watch(activeHouseIdProvider).value;
    final localMember = ref.watch(localMemberProvider).asData?.value;

    if (houseId == null) {
      return const Scaffold(body: Center(child: Text('No active house')));
    }

    final matesAsync = ref.watch(housematesProvider(houseId));

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
        title: Text('Household roster', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: matesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load roster: $e')),
          data: (mates) {
            return ListView(
              padding: EdgeInsets.all(spacing.radiusCard),
              children: [
                RemovalTargetBanner(houseId: houseId),
                Text(
                  'Members',
                  style: text.headline,
                ),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  'Active and historical members of this household.',
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: spacing.radiusCard),
                ...mates.map((mate) {
                  final inactive = isMemberInactive(mate.memberStatus);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      mate.nickname,
                      style: text.body?.copyWith(
                        color: inactive ? colors.textSecondary : colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      mate.memberStatus.name,
                      style: text.caption?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    trailing: !inactive &&
                            localMember != null &&
                            mate.memberId != localMember.memberId
                        ? TextButton(
                            onPressed: () => context.push(
                              '/removal/propose',
                              extra: mate.memberId,
                            ),
                            child: const Text('Propose removal'),
                          )
                        : null,
                  );
                }),
                SizedBox(height: spacing.radiusCard),
                if (localMember != null)
                  OutlinedButton(
                    onPressed: () => context.push('/removal/leave'),
                    child: const Text('Leave household'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
