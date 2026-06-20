import 'dart:math';

/// Generates a random roommate nickname (e.g. `Roommate-a3f2`).
String generateRandomNickname() {
  final r = Random().nextInt(0xFFFF);
  return 'Roommate-${r.toRadixString(16).padLeft(4, '0')}';
}
