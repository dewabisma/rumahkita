import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/services/tailscale_identity_binder.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

Future<void> showNetworkSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const NetworkSettingsSheet(),
  );
}

class NetworkSettingsSheet extends ConsumerStatefulWidget {
  const NetworkSettingsSheet({super.key});

  @override
  ConsumerState<NetworkSettingsSheet> createState() =>
      _NetworkSettingsSheetState();
}

class _NetworkSettingsSheetState extends ConsumerState<NetworkSettingsSheet> {
  final _authKeyController = TextEditingController();
  final _adminApiKeyController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _hasAuthKey = false;
  bool _hasAdminApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _authKeyController.dispose();
    _adminApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final localSettings = ref.read(localSettingsRepositoryProvider);
    final authKey = await localSettings.getTailscaleAuthKey();
    final adminKey = await localSettings.getTailscaleAdminApiKey();
    if (!mounted) {
      return;
    }
    setState(() {
      _hasAuthKey = authKey != null && authKey.isNotEmpty;
      _hasAdminApiKey = adminKey != null && adminKey.isNotEmpty;
      _loading = false;
    });
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
          const SnackBar(content: Text('Network settings saved')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auth key removed')),
      );
    }
  }

  Future<void> _clearAdminApiKey() async {
    final localSettings = ref.read(localSettingsRepositoryProvider);
    await localSettings.setTailscaleAdminApiKey(null);
    await _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin API key removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final isCreator = ref.watch(isHouseCreatorProvider).value ?? false;
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
                  Text('Network settings', style: text.sectionTitle),
                  SizedBox(height: spacing.radiusSmall),
                  Text(
                    'Configure how this device connects on Tailscale.',
                    style: text.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.radiusCard),
                  TextField(
                    controller: _authKeyController,
                    decoration: InputDecoration(
                      labelText: 'Tailscale auth key',
                      hintText: 'tskey-auth-...',
                      helperText: _hasAuthKey
                          ? 'A key is saved. Enter a new one to replace it.'
                          : 'Registers this device on your tailnet.',
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
                  if (isCreator) ...[
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
              ),
            ),
    );
  }
}
