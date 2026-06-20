import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.defaultTheme();
    const spacing = AppSizeTheme.defaultTheme();

    return OnboardingScaffold(
      title: 'Welcome home',
      subtitle: 'Start a shared house or join one your roommates already made.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          FilledButton(
            onPressed: () => context.push('/create'),
            child: const Text('Start a house'),
          ),
          SizedBox(height: spacing.radiusButton),
          OutlinedButton(
            onPressed: () => context.push('/join'),
            child: const Text('Join a house'),
          ),
          const Spacer(),
          Text(
            'Your data stays on your devices — we just help everyone stay in harmony.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
