import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/theme/app_colors.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.header,
    this.showBack = false,
    this.backFallback,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? header;
  final bool showBack;
  final String? backFallback;

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.defaultTheme();
    final canNavigateBack =
        showBack && (context.canPop() || backFallback != null);

    return Scaffold(
      appBar: AppBar(
        leading: canNavigateBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else if (backFallback != null) {
                    context.go(backFallback!);
                  }
                },
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
