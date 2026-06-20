import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

/// Pure redirect logic for unit tests and [routerRedirect].
String? redirectForLocation({
  required String location,
  required String? activeHouseId,
  HousePhaseContext housePhase = const HousePhaseContext(
    phase: HouseRedirectPhase.none,
  ),
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

    switch (housePhase.phase) {
      case HouseRedirectPhase.handoverCloseout:
      case HouseRedirectPhase.handoverRetro:
        if (location == '/welcome' ||
            isOnboarding ||
            location == '/lobby' ||
            location == '/home' ||
            location == '/ceremony') {
          return '/handover';
        }
      case HouseRedirectPhase.handoverCeremonyPending:
        if (location == '/welcome' ||
            isOnboarding ||
            location == '/lobby' ||
            location == '/home' ||
            location == '/handover') {
          return '/ceremony';
        }
      case HouseRedirectPhase.drafting:
        if (location == '/welcome' || isOnboarding) {
          return '/ceremony';
        }
      case HouseRedirectPhase.active:
        if (location == '/welcome' ||
            isOnboarding ||
            location == '/lobby' ||
            location == '/ceremony' ||
            location == '/handover') {
          return '/home';
        }
      case HouseRedirectPhase.none:
        if (isOnboarding || location == '/welcome') {
          return '/lobby';
        }
        if (location == '/ceremony' ||
            location == '/home' ||
            location == '/handover') {
          return '/lobby';
        }
    }
    return null;
  }

  if (location == '/lobby' ||
      location == '/ceremony' ||
      location == '/home' ||
      location == '/handover') {
    return '/welcome';
  }

  return null;
}

String? routerRedirect(Ref ref, GoRouterState state) {
  final housePhase =
      ref.read(houseRouterPhaseProvider).value ??
      const HousePhaseContext(phase: HouseRedirectPhase.none);
  return redirectForLocation(
    location: state.matchedLocation,
    activeHouseId: ref.read(activeHouseIdProvider).value,
    housePhase: housePhase,
  );
}
