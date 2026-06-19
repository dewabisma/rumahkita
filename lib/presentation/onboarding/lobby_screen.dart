import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/onboarding/widgets/member_roster_list.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';
import 'package:rumah/theme/app_colors.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const colors = AppColors.defaultTheme();
    final houseIdAsync = ref.watch(activeHouseIdProvider);

    return OnboardingScaffold(
      title: 'House lobby',
      subtitle: 'Everyone who has joined so far.',
      header: const ConnectionStatusHeader(),
      child: houseIdAsync.when(
        data: (houseId) {
          if (houseId == null) {
            return const Center(child: Text('No active house yet'));
          }
          final housematesAsync = ref.watch(housematesProvider(houseId));
          return housematesAsync.when(
            data: (mates) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: MemberRosterList(members: mates)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Ceremony coming soon — for now, enjoy getting everyone into the house.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
}
