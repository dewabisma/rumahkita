import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/app/router_redirect.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';

void main() {
  test('keeps host on /create while activeHouseId is set', () {
    expect(
      redirectForLocation(location: '/create', activeHouseId: 'house-1'),
      isNull,
    );
  });

  test('redirects /home to /handover during closeout', () {
    expect(
      redirectForLocation(
        location: '/home',
        activeHouseId: 'house-1',
        housePhase: const HousePhaseContext(
          phase: HouseRedirectPhase.handoverCloseout,
        ),
      ),
      '/handover',
    );
  });

  test('redirects /handover to /ceremony during ceremony_pending', () {
    expect(
      redirectForLocation(
        location: '/handover',
        activeHouseId: 'house-1',
        housePhase: const HousePhaseContext(
          phase: HouseRedirectPhase.handoverCeremonyPending,
        ),
      ),
      '/ceremony',
    );
  });

  test('redirects onboarding to /ceremony when drafting cycle is active', () {
    expect(
      redirectForLocation(
        location: '/welcome',
        activeHouseId: 'house-1',
        housePhase: const HousePhaseContext(phase: HouseRedirectPhase.drafting),
      ),
      '/ceremony',
    );
  });

  test('redirects to /home when cycle is active', () {
    expect(
      redirectForLocation(
        location: '/lobby',
        activeHouseId: 'house-1',
        housePhase: const HousePhaseContext(phase: HouseRedirectPhase.active),
      ),
      '/home',
    );
  });

  test('redirects /join/connect to /join without pending invite', () {
    expect(
      joinRouteRedirect(
        location: '/join/connect',
        pendingJoinInvite: null,
      ),
      '/join',
    );
  });

  test('redirects /join to /join/connect with pending invite', () {
    expect(
      joinRouteRedirect(
        location: '/join',
        pendingJoinInvite: const JoinInvitePayload(
          payloadVersion: joinInvitePayloadVersion,
          houseId: 'h1',
          hostNodeKey: 'node',
          hostMagicDns: 'host.ts.net',
          joinCredential: 'cred',
          tailscaleAuthKey: 'tskey-auth-test',
        ),
      ),
      '/join/connect',
    );
  });
}
