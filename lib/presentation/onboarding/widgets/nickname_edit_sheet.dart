import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

Future<void> showNicknameEditSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const NicknameEditSheet(),
  );
}

class NicknameEditSheet extends ConsumerStatefulWidget {
  const NicknameEditSheet({super.key});

  @override
  ConsumerState<NicknameEditSheet> createState() => _NicknameEditSheetState();
}

class _NicknameEditSheetState extends ConsumerState<NicknameEditSheet> {
  final _nicknameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _localMemberId;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadNickname() async {
    final localMember = await ref.read(localMemberProvider.future);
    if (!mounted) {
      return;
    }
    setState(() {
      _localMemberId = localMember?.memberId;
      _nicknameController.text = localMember?.nickname ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final houseId = await ref.read(activeHouseIdProvider.future);
    final memberId = _localMemberId;
    final nickname = _nicknameController.text.trim();
    if (houseId == null || memberId == null) {
      return;
    }
    if (nickname.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a nickname')),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(housemateRepositoryProvider).updateNickname(
            houseId: houseId,
            memberId: memberId,
            nickname: nickname,
          );
      await ref.read(syncServiceProvider).drainOutbox();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nickname saved')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.radiusCard,
        spacing.radiusCard,
        spacing.radiusCard,
        spacing.radiusCard + bottomInset,
      ),
      child: _loading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Your nickname', style: text.sectionTitle),
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    'How you appear to roommates in this house.',
                    style: text.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.radiusCard),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Nickname',
                      hintText: 'Roommate-a3f2',
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                  ),
                  SizedBox(height: spacing.radiusCard),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save nickname'),
                  ),
                ],
              ),
            ),
    );
  }
}
