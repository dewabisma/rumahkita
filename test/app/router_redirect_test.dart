import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/app/router_redirect.dart';

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
}
