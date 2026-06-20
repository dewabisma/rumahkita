import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/services/join_invite_codec.dart';

/// Pure redirect logic for unit tests and [routerRedirect].
String? redirectForLocation({
  required String location,
  required String? activeHouseId,
  HousePhaseContext housePhase = const HousePhaseContext(
    phase: HouseRedirectPhase.none,
  ),
  CeremonyRedirectPhase ceremonyPhase = CeremonyRedirectPhase.none,
  JoinInvitePayload? pendingJoinInvite,
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

  final joinRedirect = joinRouteRedirect(
    location: location,
    pendingJoinInvite: pendingJoinInvite,
  );
  if (joinRedirect != null) {
    return joinRedirect;
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

/// Join-flow guards: pending invite required for connect; deep-link `?p=` handling.
String? joinRouteRedirect({
  required String location,
  required JoinInvitePayload? pendingJoinInvite,
  String? deepLinkPayload,
  void Function(JoinInvitePayload invite)? onPendingInvite,
}) {
  if (location == '/join/connect' &&
      (pendingJoinInvite == null || pendingJoinInvite.tailscaleAuthKey.isEmpty)) {
    return '/join';
  }

  if (location == '/join' && pendingJoinInvite != null) {
    return '/join/connect';
  }

  if (deepLinkPayload != null && deepLinkPayload.isNotEmpty) {
    try {
      const codec = JoinInviteCodec();
      final payload = deepLinkPayload.contains('://')
          ? codec.decode(deepLinkPayload)
          : codec.decodePayloadParam(deepLinkPayload);
      onPendingInvite?.call(payload);
      return '/join/connect';
    } on Object {
      return null;
    }
  }

  return null;
}

String? routerRedirect(Ref ref, GoRouterState state) {
  final housePhase =
      ref.read(houseRouterPhaseProvider).value ??
      const HousePhaseContext(phase: HouseRedirectPhase.none);
  final onboarding = ref.read(onboardingNotifierProvider);

  final deepLinkPayload = state.uri.queryParameters[joinInviteQueryParam];

  final joinRedirect = joinRouteRedirect(
    location: state.matchedLocation,
    pendingJoinInvite: onboarding.pendingJoinInvite,
    deepLinkPayload:
        state.matchedLocation == '/join' ? deepLinkPayload : null,
    onPendingInvite: (invite) {
      ref.read(onboardingNotifierProvider.notifier).setPendingJoinInvite(invite);
    },
  );
  if (joinRedirect != null) {
    return joinRedirect;
  }

  return redirectForLocation(
    location: state.matchedLocation,
    activeHouseId: ref.read(activeHouseIdProvider).value,
    housePhase: housePhase,
    pendingJoinInvite: onboarding.pendingJoinInvite,
  );
}
