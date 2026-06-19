import 'package:flutter/material.dart';
import 'package:rumah/extension/color_extensions.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData defaultTheme(BuildContext context) {
    const colors = AppColors.defaultTheme();
    const spacing = AppSizeTheme.defaultTheme();
    final text = AppTextTheme.defaultTheme(color: colors.textPrimary);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.sproutGreen,
      onPrimary: colors.textOnSproutGreen,
      primaryContainer: colors.successSurface,
      onPrimaryContainer: colors.textOnSproutGreen,
      secondary: colors.sunnyButter,
      onSecondary: colors.textOnSunnyButter,
      secondaryContainer: colors.activeSurface,
      onSecondaryContainer: colors.textOnSunnyButter,
      tertiary: colors.droopingLeafBrown,
      onTertiary: colors.textOnDroopingLeafBrown,
      tertiaryContainer: colors.cautionSurface,
      onTertiaryContainer: colors.textOnDroopingLeafBrown,
      error: colors.caution,
      onError: colors.textOnDroopingLeafBrown,
      errorContainer: colors.cautionSurface,
      onErrorContainer: colors.textOnDroopingLeafBrown,
      surface: colors.background,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      shadow: colors.textPrimary.useOpacity(0.08),
      scrim: colors.textPrimary.useOpacity(0.32),
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.cozyLinen,
      inversePrimary: colors.successSurface,
      surfaceTint: colors.sproutGreen,
    );

    final materialTextTheme = TextTheme(
      displayLarge: text.displayTitle,
      displayMedium: text.headline,
      displaySmall: text.sectionTitle,
      headlineLarge: text.headline,
      headlineMedium: text.sectionTitle,
      headlineSmall: text.sectionTitle?.copyWith(fontSize: 18),
      titleLarge: text.sectionTitle,
      titleMedium: text.label,
      titleSmall: text.label?.copyWith(fontSize: 13),
      bodyLarge: text.body,
      bodyMedium: text.bodySmall,
      bodySmall: text.caption,
      labelLarge: text.label,
      labelMedium: text.caption,
      labelSmall: text.caption?.copyWith(fontSize: 11),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      cardColor: colors.surfaceCard,
      dividerColor: colors.separator,
      textTheme: materialTextTheme,
      primaryTextTheme: materialTextTheme,
      fontFamily: AppTextTheme.bodyFontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headline?.copyWith(
          fontSize: 22,
          color: colors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusCard),
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.sproutGreen,
          foregroundColor: colors.textOnSproutGreen,
          disabledBackgroundColor: colors.buttonDisabled,
          disabledForegroundColor: colors.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.radiusButton),
          ),
          textStyle: text.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.radiusButton),
          ),
          textStyle: text.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.sproutGreen,
          textStyle: text.label,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.sproutGreen,
        foregroundColor: colors.textOnSproutGreen,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        hintStyle: text.bodySmall?.copyWith(color: colors.textLabel),
        labelStyle: text.label?.copyWith(color: colors.textLabel),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusButton),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusButton),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusButton),
          borderSide: BorderSide(color: colors.sproutGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusButton),
          borderSide: BorderSide(color: colors.caution),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusButton),
          borderSide: BorderSide(color: colors.caution, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.sproutGreen,
        selectionColor: colors.sproutGreen.useOpacity(0.25),
        selectionHandleColor: colors.sproutGreen,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.successSurface,
        disabledColor: colors.buttonDisabled,
        labelStyle: text.caption,
        secondaryLabelStyle: text.caption,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusSmall),
        ),
        side: BorderSide(color: colors.borderSubtle),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.sheetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(spacing.radiusLarge),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: text.bodySmall?.copyWith(color: colors.cozyLinen),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusButton),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.separator,
        thickness: 1,
        space: 1,
      ),
      extensions: [
        colors,
        text,
        spacing,
      ],
    );
  }
}
