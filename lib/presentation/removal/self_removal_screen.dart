import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/removal/removal_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class SelfRemovalScreen extends ConsumerStatefulWidget {
  const SelfRemovalScreen({super.key});

  @override
  ConsumerState<SelfRemovalScreen> createState() => _SelfRemovalScreenState();
}

class _SelfRemovalScreenState extends ConsumerState<SelfRemovalScreen> {
  var _loading = false;
  var _leaving = false;
  String? _proposalId;
  String? _error;

  Future<void> _confirmLeave() async {
    final houseId = ref.read(activeHouseIdProvider).value;
    final localMember = ref.read(localMemberProvider).asData?.value;
    if (houseId == null || localMember == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave household?'),
        content: const Text(
          'This will disconnect your device from the household network. '
          'This action is recorded in the audit log.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proposal =
          await ref.read(removalRepositoryProvider).initiateSelfRemoval(
                houseId: houseId,
                targetMemberId: localMember.memberId,
              );
      setState(() {
        _proposalId = proposal.proposalId;
        _leaving = true;
      });
    } on Object catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;

    if (_proposalId != null) {
      ref.listen(removalProposalProvider(_proposalId!), (prev, next) {
        final status = next.asData?.value?.status;
        if (status == ProposalStatus.executed && mounted) {
          context.pushReplacement('/welcome');
        }
      });
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaving
              ? null
              : () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/house/roster');
                  }
                },
        ),
        automaticallyImplyLeading: false,
        title: Text('Leave household', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.radiusCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_leaving) ...[
                Text('Leaving…', style: text.headline),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  'Disconnecting your device from the household network.',
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: spacing.radiusCard),
                const Center(child: CircularProgressIndicator()),
              ] else ...[
                Text('Self-removal', style: text.headline),
                SizedBox(height: spacing.radiusSmall),
                Text(
                  'You will be removed from the household roster and your '
                  'network access will be revoked.',
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
                if (_error != null) ...[
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    _error!,
                    style: text.body?.copyWith(color: colors.caution),
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: _loading ? null : _confirmLeave,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm leave'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
