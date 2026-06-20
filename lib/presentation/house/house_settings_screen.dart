import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/services/tailscale_identity_binder.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class HouseSettingsScreen extends ConsumerStatefulWidget {
  const HouseSettingsScreen({super.key});

  @override
  ConsumerState<HouseSettingsScreen> createState() =>
      _HouseSettingsScreenState();
}

class _HouseSettingsScreenState extends ConsumerState<HouseSettingsScreen> {
  final _authKeyController = TextEditingController();
  final _adminApiKeyController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _savingNickname = false;
  bool _hasAuthKey = false;
  bool _hasAdminApiKey = false;
  String? _localMemberId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _authKeyController.dispose();
    _adminApiKeyController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final localSettings = ref.read(localSettingsRepositoryProvider);
    final authKey = await localSettings.getTailscaleAuthKey();
    final adminKey = await localSettings.getTailscaleAdminApiKey();
    final localMember = await ref.read(localMemberProvider.future);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasAuthKey = authKey != null && authKey.isNotEmpty;
      _hasAdminApiKey = adminKey != null && adminKey.isNotEmpty;
      _localMemberId = localMember?.memberId;
      _nicknameController.text = localMember?.nickname ?? '';
      _loading = false;
    });
  }

  Future<void> _saveNickname() async {
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

    setState(() => _savingNickname = true);
    try {
      await ref
          .read(housemateRepositoryProvider)
          .updateNickname(
            houseId: houseId,
            memberId: memberId,
            nickname: nickname,
          );
      await ref.read(syncServiceProvider).drainOutbox();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nickname saved')));
      }
    } finally {
      if (mounted) {
        setState(() => _savingNickname = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final localSettings = ref.read(localSettingsRepositoryProvider);
      final mesh = ref.read(meshServiceProvider);

      final authKey = _authKeyController.text.trim();
      final adminKey = _adminApiKeyController.text.trim();

      if (authKey.isNotEmpty) {
        await localSettings.setTailscaleAuthKey(authKey);
        await mesh.up(authKey: authKey);
        await resolveAndBindTailscaleNodeKey(
          localSettings: localSettings,
          deviceIdentity: ref.read(deviceIdentityProvider),
          adminApi: ref.read(appStateProvider).tailscaleAdminApi,
        );
      }
      if (adminKey.isNotEmpty) {
        await localSettings.setTailscaleAdminApiKey(adminKey);
      }

      _authKeyController.clear();
      _adminApiKeyController.clear();
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tailscale settings saved')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _clearAuthKey() async {
    final localSettings = ref.read(localSettingsRepositoryProvider);
    await localSettings.setTailscaleAuthKey(null);
    await _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Auth key removed')));
    }
  }

  Future<void> _clearAdminApiKey() async {
    final localSettings = ref.read(localSettingsRepositoryProvider);
    await localSettings.setTailscaleAdminApiKey(null);
    await _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin API key removed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final isCreator = ref.watch(isHouseCreatorProvider).value ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        automaticallyImplyLeading: false,
        title: Text('House settings', style: text.sectionTitle),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(spacing.radiusCard),
                children: [
                  Text('Your profile', style: text.headline),
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    'How you appear to roommates in this house.',
                    style: text.body?.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.radiusCard),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Nickname',
                      hintText: 'Roommate-a3f2',
                    ),
                  ),
                  SizedBox(height: spacing.radiusCard),
                  FilledButton(
                    onPressed: _savingNickname ? null : _saveNickname,
                    child: _savingNickname
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save nickname'),
                  ),
                  if (isCreator) ...[
                    SizedBox(height: spacing.radiusCard * 2),
                    Text('Tailscale network', style: text.headline),
                    SizedBox(height: spacing.radiusSmall),
                    Text(
                      'Configure how this house connects on Tailscale. '
                      'Invite roommates from the invite screen — these keys '
                      'are for advanced network setup.',
                      style: text.body?.copyWith(color: colors.textSecondary),
                    ),
                    SizedBox(height: spacing.radiusCard),
                    TextField(
                      controller: _authKeyController,
                      decoration: InputDecoration(
                        labelText: 'Tailscale auth key',
                        hintText: 'tskey-auth-...',
                        helperText: _hasAuthKey
                            ? 'A key is saved. Enter a new one to replace it.'
                            : 'Optional — registers this device on your tailnet.',
                      ),
                      obscureText: true,
                    ),
                    if (_hasAuthKey) ...[
                      SizedBox(height: spacing.radiusSmall),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _saving ? null : _clearAuthKey,
                          child: const Text('Remove auth key'),
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.radiusCard),
                    TextField(
                      controller: _adminApiKeyController,
                      decoration: InputDecoration(
                        labelText: 'Tailscale admin API key',
                        hintText: 'tskey-api-...',
                        helperText: _hasAdminApiKey
                            ? 'A key is saved. Enter a new one to replace it.'
                            : 'Needs acl:write and devices:write for house network isolation.',
                      ),
                      obscureText: true,
                    ),
                    if (_hasAdminApiKey) ...[
                      SizedBox(height: spacing.radiusSmall),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _saving ? null : _clearAdminApiKey,
                          child: const Text('Remove admin API key'),
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.radiusCard),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save network settings'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
