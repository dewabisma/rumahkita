import 'package:flutter/material.dart';

/// Rumahkita color tokens from [docs/design.md].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Brand palette
  final Color cozyLinen;
  final Color sproutGreen;
  final Color sunnyButter;
  final Color droopingLeafBrown;

  // Backgrounds & surfaces
  final Color background;
  final Color surface;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color sheetBackground;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textLabel;
  final Color textOnSproutGreen;
  final Color textOnSunnyButter;
  final Color textOnDroopingLeafBrown;

  // Semantic states
  final Color success;
  final Color successSurface;
  final Color active;
  final Color activeSurface;
  final Color caution;
  final Color cautionSurface;

  // UI elements
  final Color border;
  final Color borderSubtle;
  final Color separator;
  final Color buttonDisabled;
  final Color skeletonBase;
  final Color skeletonHighlight;

  // Companion ecosystem accents
  final Color thrivingAccent;
  final Color restAccent;
  final Color tiredAccent;

  // Role & network states
  final Color guardianAccent;
  final Color offlineMuted;
  final Color inactive;

  const AppColors({
    required this.cozyLinen,
    required this.sproutGreen,
    required this.sunnyButter,
    required this.droopingLeafBrown,
    required this.background,
    required this.surface,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.sheetBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textLabel,
    required this.textOnSproutGreen,
    required this.textOnSunnyButter,
    required this.textOnDroopingLeafBrown,
    required this.success,
    required this.successSurface,
    required this.active,
    required this.activeSurface,
    required this.caution,
    required this.cautionSurface,
    required this.border,
    required this.borderSubtle,
    required this.separator,
    required this.buttonDisabled,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.thrivingAccent,
    required this.restAccent,
    required this.tiredAccent,
    required this.guardianAccent,
    required this.offlineMuted,
    required this.inactive,
  });

  const AppColors.defaultTheme()
    : cozyLinen = const Color(0xFFF7F2EA),
      sproutGreen = const Color(0xFF8FB996),
      sunnyButter = const Color(0xFFF2E4B3),
      droopingLeafBrown = const Color(0xFFC4957A),
      background = const Color(0xFFF7F2EA),
      surface = const Color(0xFFEFEBE3),
      surfaceCard = const Color(0xFFE8E2D8),
      surfaceElevated = const Color(0xFFFFFCF7),
      sheetBackground = const Color(0xFFF0EBE2),
      textPrimary = const Color(0xFF3D3428),
      textSecondary = const Color(0xFF6B6258),
      textMuted = const Color(0xFF9A9187),
      textLabel = const Color(0xFF7A7268),
      textOnSproutGreen = const Color(0xFF2F4A36),
      textOnSunnyButter = const Color(0xFF5C4E2E),
      textOnDroopingLeafBrown = const Color(0xFF4A3228),
      success = const Color(0xFF8FB996),
      successSurface = const Color(0xFFDCEBDF),
      active = const Color(0xFFE8D494),
      activeSurface = const Color(0xFFF2E4B3),
      caution = const Color(0xFFC4957A),
      cautionSurface = const Color(0xFFE8D4C8),
      border = const Color(0xFFDDD6CB),
      borderSubtle = const Color(0xFFE5DFD5),
      separator = const Color(0xFFE5DFD5),
      buttonDisabled = const Color(0xFFD4CDC2),
      skeletonBase = const Color(0xFFE8E2D8),
      skeletonHighlight = const Color(0xFFF5F0E8),
      thrivingAccent = const Color(0xFF8FB996),
      restAccent = const Color(0xFFF2E4B3),
      tiredAccent = const Color(0xFFC4957A),
      guardianAccent = const Color(0xFF7A9E82),
      offlineMuted = const Color(0xFFB8B0A6),
      inactive = const Color(0xFFA39888);

  @override
  AppColors copyWith({
    Color? cozyLinen,
    Color? sproutGreen,
    Color? sunnyButter,
    Color? droopingLeafBrown,
    Color? background,
    Color? surface,
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? sheetBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textLabel,
    Color? textOnSproutGreen,
    Color? textOnSunnyButter,
    Color? textOnDroopingLeafBrown,
    Color? success,
    Color? successSurface,
    Color? active,
    Color? activeSurface,
    Color? caution,
    Color? cautionSurface,
    Color? border,
    Color? borderSubtle,
    Color? separator,
    Color? buttonDisabled,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? thrivingAccent,
    Color? restAccent,
    Color? tiredAccent,
    Color? guardianAccent,
    Color? offlineMuted,
    Color? inactive,
  }) {
    return AppColors(
      cozyLinen: cozyLinen ?? this.cozyLinen,
      sproutGreen: sproutGreen ?? this.sproutGreen,
      sunnyButter: sunnyButter ?? this.sunnyButter,
      droopingLeafBrown: droopingLeafBrown ?? this.droopingLeafBrown,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      sheetBackground: sheetBackground ?? this.sheetBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textLabel: textLabel ?? this.textLabel,
      textOnSproutGreen: textOnSproutGreen ?? this.textOnSproutGreen,
      textOnSunnyButter: textOnSunnyButter ?? this.textOnSunnyButter,
      textOnDroopingLeafBrown:
          textOnDroopingLeafBrown ?? this.textOnDroopingLeafBrown,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      active: active ?? this.active,
      activeSurface: activeSurface ?? this.activeSurface,
      caution: caution ?? this.caution,
      cautionSurface: cautionSurface ?? this.cautionSurface,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      separator: separator ?? this.separator,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      thrivingAccent: thrivingAccent ?? this.thrivingAccent,
      restAccent: restAccent ?? this.restAccent,
      tiredAccent: tiredAccent ?? this.tiredAccent,
      guardianAccent: guardianAccent ?? this.guardianAccent,
      offlineMuted: offlineMuted ?? this.offlineMuted,
      inactive: inactive ?? this.inactive,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return AppColors(
      cozyLinen: l(cozyLinen, other.cozyLinen),
      sproutGreen: l(sproutGreen, other.sproutGreen),
      sunnyButter: l(sunnyButter, other.sunnyButter),
      droopingLeafBrown: l(droopingLeafBrown, other.droopingLeafBrown),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceCard: l(surfaceCard, other.surfaceCard),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      sheetBackground: l(sheetBackground, other.sheetBackground),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      textLabel: l(textLabel, other.textLabel),
      textOnSproutGreen: l(textOnSproutGreen, other.textOnSproutGreen),
      textOnSunnyButter: l(textOnSunnyButter, other.textOnSunnyButter),
      textOnDroopingLeafBrown:
          l(textOnDroopingLeafBrown, other.textOnDroopingLeafBrown),
      success: l(success, other.success),
      successSurface: l(successSurface, other.successSurface),
      active: l(active, other.active),
      activeSurface: l(activeSurface, other.activeSurface),
      caution: l(caution, other.caution),
      cautionSurface: l(cautionSurface, other.cautionSurface),
      border: l(border, other.border),
      borderSubtle: l(borderSubtle, other.borderSubtle),
      separator: l(separator, other.separator),
      buttonDisabled: l(buttonDisabled, other.buttonDisabled),
      skeletonBase: l(skeletonBase, other.skeletonBase),
      skeletonHighlight: l(skeletonHighlight, other.skeletonHighlight),
      thrivingAccent: l(thrivingAccent, other.thrivingAccent),
      restAccent: l(restAccent, other.restAccent),
      tiredAccent: l(tiredAccent, other.tiredAccent),
      guardianAccent: l(guardianAccent, other.guardianAccent),
      offlineMuted: l(offlineMuted, other.offlineMuted),
      inactive: l(inactive, other.inactive),
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get themeColors => Theme.of(this).extension<AppColors>()!;
}
