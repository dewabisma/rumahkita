import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/domain/entities/privilege_state.dart';
import 'package:rumah/presentation/home/privilege_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class MemberPrivilegesSection extends ConsumerWidget {
  const MemberPrivilegesSection({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final statesAsync = ref.watch(localMemberPrivilegeStatesProvider(houseId));

    return statesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (states) {
        if (states.isEmpty) {
          return const SizedBox.shrink();
        }
        final active = activePerks(states);
        final resting = inactivePerks(states);

        return Card(
          color: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your perks', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                if (active.isEmpty && resting.isEmpty)
                  Text(
                    'Keep earning points to unlock house perks.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  )
                else ...[
                  if (active.isNotEmpty) ...[
                    Text(
                      'Active now',
                      style: text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.radiusSmall / 2),
                    Wrap(
                      spacing: spacing.radiusSmall / 2,
                      runSpacing: spacing.radiusSmall / 2,
                      children: active
                          .map(
                            (s) => _PerkChip(
                              state: s,
                              colors: colors,
                              text: text,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (resting.isNotEmpty) ...[
                    SizedBox(height: spacing.radiusSmall),
                    Text(
                      'Resting for now',
                      style: text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.radiusSmall / 2),
                    Wrap(
                      spacing: spacing.radiusSmall / 2,
                      runSpacing: spacing.radiusSmall / 2,
                      children: resting
                          .map(
                            (s) => _PerkChip(
                              state: s,
                              colors: colors,
                              text: text,
                              inactive: true,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PerkChip extends StatelessWidget {
  const _PerkChip({
    required this.state,
    required this.colors,
    required this.text,
    this.inactive = false,
  });

  final PrivilegeState state;
  final AppColors colors;
  final AppTextTheme text;
  final bool inactive;

  @override
  Widget build(BuildContext context) {
    final isPenalty = state.isPenalty && state.isActive;
    final background = inactive || isPenalty
        ? colors.cautionSurface
        : colors.successSurface;
    final foreground = inactive || isPenalty
        ? colors.droopingLeafBrown
        : colors.sproutGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        state.name,
        style: text.bodySmall?.copyWith(color: foreground),
      ),
    );
  }
}
