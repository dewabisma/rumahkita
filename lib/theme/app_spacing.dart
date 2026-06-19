import 'package:flutter/material.dart';

@immutable
class AppSizeTheme extends ThemeExtension<AppSizeTheme> {
  /// Fully rounded pill shape.
  final double radiusFull;

  /// Cards, sheets, and primary containers (design minimum: 16px).
  final double radiusCard;

  /// Buttons, chips, and inline containers.
  final double radiusButton;

  /// Small tags and compact controls.
  final double radiusSmall;

  /// Large hero surfaces and modals.
  final double radiusLarge;

  const AppSizeTheme({
    required this.radiusFull,
    required this.radiusCard,
    required this.radiusButton,
    required this.radiusSmall,
    required this.radiusLarge,
  });

  const AppSizeTheme.defaultTheme()
    : radiusFull = 999,
      radiusCard = 16,
      radiusButton = 16,
      radiusSmall = 12,
      radiusLarge = 24;

  @override
  AppSizeTheme copyWith({
    double? radiusFull,
    double? radiusCard,
    double? radiusButton,
    double? radiusSmall,
    double? radiusLarge,
  }) {
    return AppSizeTheme(
      radiusFull: radiusFull ?? this.radiusFull,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusButton: radiusButton ?? this.radiusButton,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusLarge: radiusLarge ?? this.radiusLarge,
    );
  }

  @override
  AppSizeTheme lerp(AppSizeTheme? other, double t) {
    if (other is! AppSizeTheme) return this;
    double l(double a, double b) => a + (b - a) * t;

    return AppSizeTheme(
      radiusFull: l(radiusFull, other.radiusFull),
      radiusCard: l(radiusCard, other.radiusCard),
      radiusButton: l(radiusButton, other.radiusButton),
      radiusSmall: l(radiusSmall, other.radiusSmall),
      radiusLarge: l(radiusLarge, other.radiusLarge),
    );
  }
}

extension AppSizeThemeExtension on BuildContext {
  AppSizeTheme get themeSpacing => Theme.of(this).extension<AppSizeTheme>()!;
}
