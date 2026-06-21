import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/entities/house_privilege.dart';
import 'package:rumah/domain/entities/privilege_state.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/home/privilege_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
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
    final walletAsync = ref.watch(localMemberPrivilegeWalletProvider(houseId));

    return walletAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (wallet) {
        if (wallet.catalog.isEmpty && wallet.entitlements.isEmpty) {
          return const SizedBox.shrink();
        }
        final active = activeEntitlements(wallet.entitlements);
        final ownedPrivilegeIds = active.map((s) => s.privilegeId).toSet();
        final redeemableCatalog = wallet.catalog
            .where((p) => !ownedPrivilegeIds.contains(p.privilegeId))
            .toList();

        return Card(
          color: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your perks', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(spacing.radiusSmall),
                  decoration: BoxDecoration(
                    color: colors.activeSurface,
                    borderRadius: BorderRadius.circular(spacing.radiusCard),
                  ),
                  child: Text(
                    'Points balance: ${wallet.balance}',
                    style: text.body?.copyWith(color: colors.textOnSunnyButter),
                  ),
                ),
                if (active.isNotEmpty) ...[
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    'Active now',
                    style: text.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.radiusSmall / 2),
                  Wrap(
                    spacing: spacing.radiusSmall / 2,
                    runSpacing: spacing.radiusSmall / 2,
                    children: active
                        .map(
                          (s) => _EntitlementChip(
                            state: s,
                            colors: colors,
                            text: text,
                            onConsume: s.isOneShot
                                ? () => _consumeRedemption(context, ref, s)
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (redeemableCatalog.isNotEmpty) ...[
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    'Redeem with points',
                    style: text.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.radiusSmall / 2),
                  ...redeemableCatalog.map(
                    (privilege) => _CatalogTile(
                      privilege: privilege,
                      balance: wallet.balance,
                      colors: colors,
                      text: text,
                      spacing: spacing,
                      onRedeem: () => _confirmRedeem(context, ref, privilege),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRedeem(
    BuildContext context,
    WidgetRef ref,
    HousePrivilege privilege,
  ) async {
    final member = await ref.read(localMemberProvider.future);
    final cycle = await ref.read(activeCycleProvider(houseId).future);
    if (member == null || cycle == null || !context.mounted) {
      return;
    }
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final wallet =
        ref.read(localMemberPrivilegeWalletProvider(houseId)).asData?.value;
    final balance = wallet?.balance ?? 0;
    final canAfford = balance >= privilege.pointCost;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.radiusCard),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Redeem ${privilege.name}?', style: text.sectionTitle),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  privilege.description,
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  'Cost: ${privilege.pointCost} points',
                  style: text.body?.copyWith(color: colors.textPrimary),
                ),
                if (!canAfford) ...[
                  SizedBox(height: spacing.radiusSmall / 2),
                  Text(
                    'You need a few more points for this perk.',
                    style: text.bodySmall?.copyWith(color: colors.caution),
                  ),
                ],
                SizedBox(height: spacing.radiusCard),
                FilledButton(
                  onPressed: canAfford ? () => Navigator.pop(ctx, true) : null,
                  child: const Text('Redeem'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Not now'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(ceremonyRepositoryProvider).redeemPrivilege(
            houseId: houseId,
            cycleId: cycle.cycleId,
            privilegeId: privilege.privilegeId,
            memberId: member.memberId,
          );
    } on StateError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: colors.surfaceElevated,
          ),
        );
      }
    } on CeremonyOperationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: colors.surfaceElevated,
          ),
        );
      }
    }
  }

  Future<void> _consumeRedemption(
    BuildContext context,
    WidgetRef ref,
    PrivilegeState state,
  ) async {
    final member = await ref.read(localMemberProvider.future);
    if (member == null || !context.mounted) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).consumeRedemption(
          houseId: houseId,
          redemptionId: state.redemption.redemptionId,
          actorMemberId: member.memberId,
        );
  }
}

class _EntitlementChip extends StatelessWidget {
  const _EntitlementChip({
    required this.state,
    required this.colors,
    required this.text,
    this.onConsume,
  });

  final PrivilegeState state;
  final AppColors colors;
  final AppTextTheme text;
  final VoidCallback? onConsume;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(
        state.name,
        style: text.bodySmall?.copyWith(color: colors.textOnSproutGreen),
      ),
      backgroundColor: colors.successSurface,
      onPressed: onConsume,
      deleteIcon: onConsume != null
          ? Icon(Icons.check, size: 16, color: colors.sproutGreen)
          : null,
      onDeleted: onConsume,
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.privilege,
    required this.balance,
    required this.colors,
    required this.text,
    required this.spacing,
    required this.onRedeem,
  });

  final HousePrivilege privilege;
  final int balance;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final canAfford = balance >= privilege.pointCost;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(privilege.name, style: text.body),
      subtitle: Text(
        '${privilege.pointCost} pts · ${privilege.description}',
        style: text.bodySmall?.copyWith(color: colors.textSecondary),
      ),
      trailing: TextButton(
        onPressed: canAfford ? onRedeem : null,
        child: const Text('Redeem'),
      ),
    );
  }
}
