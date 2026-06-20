import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/router_redirect.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/ceremony/ceremony_screen.dart';
import 'package:rumah/presentation/house/handover_screen.dart';
import 'package:rumah/presentation/house/house_settings_screen.dart';
import 'package:rumah/presentation/house/member_roster_screen.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/home/home_screen.dart';
import 'package:rumah/presentation/removal/propose_eviction_screen.dart';
import 'package:rumah/presentation/removal/removal_proposal_screen.dart';
import 'package:rumah/presentation/removal/self_removal_screen.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/dev/sync_debug_panel.dart';
import 'package:rumah/presentation/onboarding/create_house_screen.dart';
import 'package:rumah/presentation/onboarding/invite_screen.dart';
import 'package:rumah/presentation/onboarding/join_connect_screen.dart';
import 'package:rumah/presentation/onboarding/join_scan_screen.dart';
import 'package:rumah/presentation/onboarding/lobby_screen.dart';
import 'package:rumah/presentation/onboarding/welcome_screen.dart';
import 'package:rumah/sync/handover_expiry_watcher.dart';
import 'package:rumah/sync/removal_execution_watcher.dart';
import 'package:rumah/sync/removal_proposal_expiry_watcher.dart';

final rootScaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
      (ref) => GlobalKey<ScaffoldMessengerState>(),
    );

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen(activeHouseIdProvider, (_, _) => notifyListeners());
    ref.listen(houseRouterPhaseProvider, (_, _) => notifyListeners());
    ref.listen(onboardingNotifierProvider, (_, _) => notifyListeners());
  }
}

final _routerRefreshListenableProvider = Provider<_RouterRefreshListenable>((
  ref,
) {
  final listenable = _RouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshListenableProvider);
  final scaffoldKey = ref.watch(rootScaffoldMessengerKeyProvider);
  ref.watch(handoverExpiryWatcherProvider);
  ref.watch(removalProposalExpiryWatcherProvider);
  ref.watch(removalExecutionWatcherProvider);

  final router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refreshListenable,
    redirect: (context, state) => routerRedirect(ref, state),
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateHouseScreen(),
      ),
      GoRoute(
        path: '/invite',
        builder: (context, state) => const InviteScreen(),
      ),
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinScanScreen(),
        routes: [
          GoRoute(
            path: 'connect',
            builder: (context, state) => const JoinConnectScreen(),
          ),
        ],
      ),
      GoRoute(path: '/lobby', builder: (context, state) => const LobbyScreen()),
      GoRoute(
        path: '/ceremony',
        builder: (context, state) => const CeremonyScreen(),
      ),
      GoRoute(
        path: '/handover',
        builder: (context, state) => const HandoverScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/house/roster',
        builder: (context, state) => const MemberRosterScreen(),
      ),
      GoRoute(
        path: '/house/settings',
        builder: (context, state) => const HouseSettingsScreen(),
      ),
      GoRoute(
        path: '/removal/propose',
        builder: (context, state) =>
            ProposeEvictionScreen(targetMemberId: state.extra as String?),
      ),
      GoRoute(
        path: '/removal/leave',
        builder: (context, state) => const SelfRemovalScreen(),
      ),
      GoRoute(
        path: '/removal/:proposalId',
        builder: (context, state) => RemovalProposalScreen(
          proposalId: state.pathParameters['proposalId']!,
        ),
      ),
      GoRoute(
        path: '/dev/sync',
        builder: (context, state) => const SyncDebugPanel(),
      ),
    ],
  );

  ref.listen<OnboardingState>(onboardingNotifierProvider, (prev, next) {
    final location = router.state.matchedLocation;

    if (prev?.phase != LobbyPhase.ready &&
        next.phase == LobbyPhase.ready &&
        next.inviteLink != null &&
        location == '/create') {
      router.pushReplacement('/invite');
    }

    if (prev?.phase != LobbyPhase.error &&
        next.phase == LobbyPhase.error &&
        next.errorMessage != null) {
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text(next.errorMessage!)),
      );
    }
  });

  return router;
});
