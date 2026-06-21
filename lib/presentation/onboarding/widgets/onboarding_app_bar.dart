import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_settings_action_sheet.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_text_styles.dart';

class OnboardingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const OnboardingAppBar({
    super.key,
    this.showBack = false,
    this.backFallback,
    this.onBack,
    this.showSettingsMenu = false,
  });

  final bool showBack;
  final String? backFallback;
  final Future<void> Function()? onBack;
  final bool showSettingsMenu;

  static const double _toolbarHeight = kToolbarHeight;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final canNavigateBack =
        showBack && (context.canPop() || backFallback != null);

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: canNavigateBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (onBack != null) {
                  await onBack!();
                } else if (context.canPop()) {
                  context.pop();
                } else if (backFallback != null) {
                  context.go(backFallback!);
                }
              },
            )
          : null,
      title: canNavigateBack
          ? null
          : Text(
              'Rumahkita',
              style: text.sectionTitle?.copyWith(color: colors.textPrimary),
            ),
      actions: [
        if (showSettingsMenu)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showOnboardingSettingsActionSheet(context, ref),
          ),
      ],
    );
  }
}
