import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/onboarding/widgets/invite_qr_card.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';
import 'package:rumah/theme/app_spacing.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _loadingInvite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureInviteLink());
  }

  Future<void> _ensureInviteLink() async {
    if (ref.read(onboardingNotifierProvider).inviteLink != null) {
      return;
    }
    await _regenerateInvite();
  }

  Future<void> _regenerateInvite() async {
    if (_loadingInvite) {
      return;
    }
    setState(() => _loadingInvite = true);
    try {
      await ref.read(onboardingNotifierProvider.notifier).regenerateInvite();
    } finally {
      if (mounted) {
        setState(() => _loadingInvite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final onboarding = ref.watch(onboardingNotifierProvider);
    final inviteLink = onboarding.inviteLink;
    final canShareInviteAsync = ref.watch(canShareInviteProvider);

    return canShareInviteAsync.when(
      data: (canShare) {
        if (!canShare) {
          return OnboardingScaffold(
            title: 'Invite roommates',
            subtitle: 'Only the house host can share invite codes.',
            showBack: true,
            backFallback: '/lobby',
            child: Center(
              child: FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Back to lobby'),
              ),
            ),
          );
        }

        return OnboardingScaffold(
          title: 'Invite roommates',
          subtitle: 'Have your roommate scan this QR code from Join a house.',
          showBack: true,
          backFallback: '/lobby',
          header: const ConnectionStatusHeader(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loadingInvite && inviteLink == null)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                if (inviteLink != null) InviteQrCard(inviteLink: inviteLink),
                SizedBox(height: spacing.radiusSmall),
                TextButton(
                  onPressed:
                      _loadingInvite || onboarding.phase == LobbyPhase.syncing
                      ? null
                      : _regenerateInvite,
                  child: const Text('Refresh invite code'),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Back to lobby'),
              ),
            ],
          ),
        );
      },
      loading: () => const OnboardingScaffold(
        title: 'Invite roommates',
        subtitle: 'Loading…',
        showBack: true,
        backFallback: '/lobby',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => OnboardingScaffold(
        title: 'Invite roommates',
        subtitle: 'Something went wrong.',
        showBack: true,
        backFallback: '/lobby',
        child: Center(child: Text('Error: $e')),
      ),
    );
  }
}
