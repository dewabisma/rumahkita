import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/repositories/removal_repository.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/removal/removal_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class ProposeEvictionScreen extends ConsumerStatefulWidget {
  const ProposeEvictionScreen({super.key, this.targetMemberId});

  final String? targetMemberId;

  @override
  ConsumerState<ProposeEvictionScreen> createState() =>
      _ProposeEvictionScreenState();
}

class _ProposeEvictionScreenState extends ConsumerState<ProposeEvictionScreen> {
  String? _selectedTargetId;
  final _justificationController = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTargetId = widget.targetMemberId;
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final houseId = ref.read(activeHouseIdProvider).value;
    final localMember = ref.read(localMemberProvider).asData?.value;
    final targetId = _selectedTargetId;
    if (houseId == null || localMember == null || targetId == null) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proposal = await ref.read(removalRepositoryProvider).proposeEviction(
            houseId: houseId,
            proposerMemberId: localMember.memberId,
            targetMemberId: targetId,
            justificationNotes: _justificationController.text.trim().isEmpty
                ? null
                : _justificationController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      context.pushReplacement('/removal/${proposal.proposalId}');
    } on GuardianEvictionBlockedException {
      setState(() {
        _error =
            'This member is the active guardian and cannot be removed during a live cycle.';
      });
    } on RemovalProposalConflictException {
      setState(() {
        _error = 'A removal proposal for this member is already in progress.';
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
    final houseId = ref.watch(activeHouseIdProvider).value;
    final localMember = ref.watch(localMemberProvider).asData?.value;

    if (houseId == null) {
      return const Scaffold(body: Center(child: Text('No active house')));
    }

    final mates =
        ref.watch(housematesProvider(houseId)).asData?.value ?? const [];
    final eligible = mates
        .where(
          (m) =>
              !isMemberInactive(m.memberStatus) &&
              m.memberId != localMember?.memberId,
        )
        .toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/house/roster');
            }
          },
        ),
        automaticallyImplyLeading: false,
        title: Text('Propose removal', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.radiusCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Eviction proposal',
                style: text.headline,
              ),
              SizedBox(height: spacing.radiusSmall),
              Text(
                'A majority vote of active members is required. Voting window: 7 days.',
                style: text.body?.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.radiusCard),
              DropdownButtonFormField<String>(
                initialValue: _selectedTargetId,
                decoration: const InputDecoration(labelText: 'Member'),
                items: eligible
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.memberId,
                        child: Text(m.nickname),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _selectedTargetId = v),
              ),
              SizedBox(height: spacing.radiusCard),
              TextField(
                controller: _justificationController,
                enabled: !_loading,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  alignLabelWithHint: true,
                ),
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
                onPressed: _loading || _selectedTargetId == null ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
