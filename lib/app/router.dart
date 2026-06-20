import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/router_redirect.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/ceremony/ceremony_screen.dart';
import 'package:rumah/presentation/house/handover_screen.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/home/home_screen.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/dev/sync_debug_panel.dart';
import 'package:rumah/presentation/onboarding/create_house_screen.dart';
import 'package:rumah/presentation/onboarding/invite_screen.dart';
import 'package:rumah/presentation/onboarding/join_house_screen.dart';
import 'package:rumah/presentation/onboarding/lobby_screen.dart';
import 'package:rumah/presentation/onboarding/welcome_screen.dart';
import 'package:rumah/sync/handover_expiry_watcher.dart';

final rootScaffoldMessengerKeyProvider = Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen(activeHouseIdProvider, (_, _) => notifyListeners());
    ref.listen(houseRouterPhaseProvider, (_, _) => notifyListeners());
  }
}

final _routerRefreshListenableProvider =
    Provider<_RouterRefreshListenable>((ref) {
  final listenable = _RouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshListenableProvider);
  final scaffoldKey = ref.watch(rootScaffoldMessengerKeyProvider);
  ref.watch(handoverExpiryWatcherProvider);

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
        builder: (context, state) => JoinHouseScreen(
          deepLinkPayload: state.uri.queryParameters['p'],
        ),
      ),
      GoRoute(
        path: '/join/:payload',
        builder: (context, state) => JoinHouseScreen(
          deepLinkPayload: state.pathParameters['payload'],
        ),
      ),
      GoRoute(
        path: '/lobby',
        builder: (context, state) => const LobbyScreen(),
      ),
      GoRoute(
        path: '/ceremony',
        builder: (context, state) => const CeremonyScreen(),
      ),
      GoRoute(
        path: '/handover',
        builder: (context, state) => const HandoverScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
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
