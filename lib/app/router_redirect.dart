import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

/// Pure redirect logic for unit tests and [routerRedirect].
String? redirectForLocation({
  required String location,
  required String? activeHouseId,
  CeremonyRedirectPhase ceremonyPhase = CeremonyRedirectPhase.none,
}) {
  const onboardingPaths = {
    '/welcome',
    '/create',
    '/invite',
    '/join',
  };

  final isOnboarding = onboardingPaths.any(
    (path) => location == path || location.startsWith('/join'),
  );
  final isDev = location.startsWith('/dev');

  if (isDev) {
    return null;
  }

  if (activeHouseId != null && activeHouseId.isNotEmpty) {
    if (location == '/create' || location == '/invite') {
      return null;
    }

    switch (ceremonyPhase) {
      case CeremonyRedirectPhase.active:
        if (location == '/welcome' ||
            isOnboarding ||
            location == '/lobby' ||
            location == '/ceremony') {
          return '/home';
        }
      case CeremonyRedirectPhase.drafting:
        if (location == '/welcome' ||
            isOnboarding ||
            location == '/lobby') {
          return '/ceremony';
        }
      case CeremonyRedirectPhase.none:
        if (isOnboarding || location == '/welcome') {
          return '/lobby';
        }
        if (location == '/ceremony' || location == '/home') {
          return '/lobby';
        }
    }
    return null;
  }

  if (location == '/lobby' ||
      location == '/ceremony' ||
      location == '/home') {
    return '/welcome';
  }

  return null;
}

String? routerRedirect(Ref ref, GoRouterState state) {
  final ceremonyPhase =
      ref.read(ceremonyRouterPhaseProvider).value ?? CeremonyRedirectPhase.none;
  return redirectForLocation(
    location: state.matchedLocation,
    activeHouseId: ref.read(activeHouseIdProvider).value,
    ceremonyPhase: ceremonyPhase,
  );
}
