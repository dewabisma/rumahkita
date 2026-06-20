import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class JoinConnectScreen extends ConsumerStatefulWidget {
  const JoinConnectScreen({super.key});

  @override
  ConsumerState<JoinConnectScreen> createState() => _JoinConnectScreenState();
}

class _JoinConnectScreenState extends ConsumerState<JoinConnectScreen> {
  bool _connectStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConnect());
  }

  Future<void> _startConnect() async {
    if (!mounted) {
      return;
    }
    if (ref.read(onboardingNotifierProvider).pendingJoinInvite == null) {
      return;
    }
    if (_connectStarted) {
      return;
    }
    _connectStarted = true;

    await ref.read(onboardingNotifierProvider.notifier).connectJoiner();
    if (!mounted) {
      return;
    }

    final state = ref.read(onboardingNotifierProvider);
    if (state.phase == LobbyPhase.ready) {
      context.pushReplacement('/lobby');
      return;
    }
    if (state.phase == LobbyPhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Join failed')),
      );
    }
  }

  Future<void> _retryConnect() async {
    _connectStarted = false;
    await _startConnect();
  }

  Future<void> _abortAndLeave() async {
    await ref.read(onboardingNotifierProvider.notifier).abortJoiner();
    if (mounted) {
      context.go('/join');
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final text = context.themeText;
    final onboarding = ref.watch(onboardingNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _abortAndLeave();
      },
      child: OnboardingScaffold(
        title: 'Connecting',
        subtitle: 'Setting up your connection and joining the house.',
        showBack: true,
        onBack: _abortAndLeave,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ConnectionStatusHeader(),
            SizedBox(height: spacing.radiusCard),
            const Spacer(),
            const Center(child: CircularProgressIndicator()),
            SizedBox(height: spacing.radiusCard),
            Text(
              _phaseLabel(onboarding.phase),
              style: text.body,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (onboarding.phase == LobbyPhase.error) ...[
              FilledButton(
                onPressed: _retryConnect,
                child: const Text('Try again'),
              ),
              SizedBox(height: spacing.radiusSmall),
              OutlinedButton(
                onPressed: _abortAndLeave,
                child: const Text('Back to scan'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _phaseLabel(LobbyPhase phase) {
    return switch (phase) {
      LobbyPhase.connectingTailscale => 'Connecting to Tailscale…',
      LobbyPhase.catchingUp => 'Catching up with the house…',
      LobbyPhase.replayingHistory => 'Syncing house history…',
      LobbyPhase.joiningHouse => 'Joining as a roommate…',
      LobbyPhase.syncing => 'Finishing sync…',
      LobbyPhase.error => 'Something went wrong.',
      _ => 'Working on it…',
    };
  }
}
