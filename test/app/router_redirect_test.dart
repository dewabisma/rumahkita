import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/app/router_redirect.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';

void main() {
  test('keeps host on /create while activeHouseId is set', () {
    expect(
      redirectForLocation(location: '/create', activeHouseId: 'house-1'),
      isNull,
    );
  });

  test('keeps host on /invite while activeHouseId is set', () {
    expect(
      redirectForLocation(location: '/invite', activeHouseId: 'house-1'),
      isNull,
    );
  });

  test('redirects other onboarding paths to /lobby when house is active', () {
    expect(
      redirectForLocation(location: '/welcome', activeHouseId: 'house-1'),
      '/lobby',
    );
  });

  test('redirects /lobby to /welcome when no active house', () {
    expect(
      redirectForLocation(location: '/lobby', activeHouseId: null),
      '/welcome',
    );
  });

  test('redirects to /ceremony when drafting cycle is active', () {
    expect(
      redirectForLocation(
        location: '/lobby',
        activeHouseId: 'house-1',
        ceremonyPhase: CeremonyRedirectPhase.drafting,
      ),
      '/ceremony',
    );
  });

  test('redirects to /home when cycle is active', () {
    expect(
      redirectForLocation(
        location: '/lobby',
        activeHouseId: 'house-1',
        ceremonyPhase: CeremonyRedirectPhase.active,
      ),
      '/home',
    );
  });

  test('redirects /ceremony to /lobby when no ceremony phase', () {
    expect(
      redirectForLocation(
        location: '/ceremony',
        activeHouseId: 'house-1',
        ceremonyPhase: CeremonyRedirectPhase.none,
      ),
      '/lobby',
    );
  });
}
