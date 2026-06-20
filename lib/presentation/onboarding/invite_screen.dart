import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/onboarding/widgets/invite_qr_card.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingNotifierProvider);
    final inviteLink = onboarding.inviteLink;

    return OnboardingScaffold(
      title: 'Invite roommates',
      subtitle: 'Have your roommate scan this QR code to join your house.',
      showBack: true,
      backFallback: '/welcome',
      header: const ConnectionStatusHeader(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (inviteLink != null) InviteQrCard(inviteLink: inviteLink),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onboarding.phase == LobbyPhase.syncing
                ? null
                : () => ref
                    .read(onboardingNotifierProvider.notifier)
                    .regenerateInvite(),
            child: const Text('Regenerate invite'),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => context.push('/lobby'),
            child: const Text('Go to lobby'),
          ),
        ],
      ),
    );
  }
}
