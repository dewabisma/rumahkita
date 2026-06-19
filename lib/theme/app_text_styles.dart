import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens from [docs/design.md]: Fredoka for headings, Nunito for body.
@immutable
class AppTextTheme extends ThemeExtension<AppTextTheme> {
  static String get headingFontFamily => GoogleFonts.fredoka().fontFamily!;
  static String get bodyFontFamily => GoogleFonts.nunito().fontFamily!;

  /// House naming, score callouts, and hero titles.
  final TextStyle? displayTitle;

  /// Primary navigation headers and section titles.
  final TextStyle? headline;

  /// Card titles and secondary headings.
  final TextStyle? sectionTitle;

  /// Chore descriptions, settings, and general copy.
  final TextStyle? body;

  /// Supporting descriptions and log text.
  final TextStyle? bodySmall;

  /// Large numeric score callouts.
  final TextStyle? scoreCallout;

  /// Form labels and metadata.
  final TextStyle? label;

  /// Timestamps, badges, and fine print.
  final TextStyle? caption;

  const AppTextTheme({
    this.displayTitle,
    this.headline,
    this.sectionTitle,
    this.body,
    this.bodySmall,
    this.scoreCallout,
    this.label,
    this.caption,
  });

  factory AppTextTheme.defaultTheme({Color? color}) {
    final heading = GoogleFonts.fredoka(color: color);
    final bodyStyle = GoogleFonts.nunito(color: color);

    return AppTextTheme(
      displayTitle: heading.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      headline: heading.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      sectionTitle: heading.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      body: bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      scoreCallout: heading.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        height: 1.0,
      ),
      label: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.2,
      ),
      caption: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
    );
  }

  @override
  AppTextTheme copyWith({
    TextStyle? displayTitle,
    TextStyle? headline,
    TextStyle? sectionTitle,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? scoreCallout,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return AppTextTheme(
      displayTitle: displayTitle ?? this.displayTitle,
      headline: headline ?? this.headline,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      scoreCallout: scoreCallout ?? this.scoreCallout,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTextTheme lerp(AppTextTheme? other, double t) {
    if (other is! AppTextTheme) return this;
    return AppTextTheme(
      displayTitle: TextStyle.lerp(displayTitle, other.displayTitle, t),
      headline: TextStyle.lerp(headline, other.headline, t),
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t),
      body: TextStyle.lerp(body, other.body, t),
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t),
      scoreCallout: TextStyle.lerp(scoreCallout, other.scoreCallout, t),
      label: TextStyle.lerp(label, other.label, t),
      caption: TextStyle.lerp(caption, other.caption, t),
    );
  }
}

extension AppTextThemeExtension on BuildContext {
  AppTextTheme get themeText => Theme.of(this).extension<AppTextTheme>()!;
}
