import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/home/guardian_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class CurrentGuardianBanner extends ConsumerWidget {
  const CurrentGuardianBanner({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final activeCycle = ref.watch(activeCycleProvider(houseId)).value;
    if (activeCycle == null) {
      return const SizedBox.shrink();
    }

    final guardianAsync = ref.watch(currentGuardianProvider(houseId));
    return guardianAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (guardian) {
        final nickname = guardian?.nickname ?? 'your housemate';
        return Card(
          color: colors.guardianAccent.withValues(alpha: 0.15),
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: colors.guardianAccent),
                SizedBox(width: spacing.radiusSmall),
                Expanded(
                  child: Text(
                    '$nickname is guardian this cycle',
                    style: text.body?.copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
