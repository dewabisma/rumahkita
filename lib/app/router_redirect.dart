import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

/// Pure redirect logic for unit tests and [routerRedirect].
String? redirectForLocation({
  required String location,
  required String? activeHouseId,
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
    // Host may still be on /create or /invite while bootstrap finishes.
    if (location == '/create' || location == '/invite') {
      return null;
    }
    if (isOnboarding || location == '/welcome') {
      return '/lobby';
    }
    return null;
  }

  if (location == '/lobby') {
    return '/welcome';
  }

  return null;
}

String? routerRedirect(Ref ref, GoRouterState state) {
  return redirectForLocation(
    location: state.matchedLocation,
    activeHouseId: ref.read(activeHouseIdProvider).value,
  );
}
