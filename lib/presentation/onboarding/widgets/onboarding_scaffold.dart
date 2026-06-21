import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_app_bar.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.header,
    this.showBack = false,
    this.backFallback,
    this.onBack,
    this.showSettingsMenu = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? header;
  final bool showBack;
  final String? backFallback;
  final Future<void> Function()? onBack;
  final bool showSettingsMenu;

  Future<void> _handleBack(BuildContext context) async {
    if (onBack != null) {
      await onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else if (backFallback != null) {
      context.go(backFallback!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final canNavigateBack =
        showBack && (context.canPop() || backFallback != null);
    final inlineBack = canNavigateBack && !showSettingsMenu;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: showSettingsMenu
          ? OnboardingAppBar(
              showBack: showBack,
              backFallback: backFallback,
              onBack: onBack,
              showSettingsMenu: true,
            )
          : null,
      body: SafeArea(
        top: !showSettingsMenu,
        child: Padding(
          padding: EdgeInsets.all(spacing.radiusCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (inlineBack) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () => _handleBack(context),
                  ),
                ),
                SizedBox(height: spacing.radiusSmall),
              ],
              if (header != null) ...[
                header!,
                SizedBox(height: spacing.radiusCard),
              ],
              Text(
                title,
                style: text.sectionTitle?.copyWith(color: colors.textPrimary),
              ),
              SizedBox(height: spacing.radiusSmall),
              Text(
                subtitle,
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.radiusLarge),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
