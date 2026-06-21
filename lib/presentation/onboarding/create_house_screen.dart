import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/domain/generate_random_nickname.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';

class CreateHouseScreen extends ConsumerStatefulWidget {
  const CreateHouseScreen({super.key});

  @override
  ConsumerState<CreateHouseScreen> createState() => _CreateHouseScreenState();
}

class _CreateHouseScreenState extends ConsumerState<CreateHouseScreen> {
  final _displayNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _authKeyController = TextEditingController();
  final _adminApiKeyController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = generateRandomNickname();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nicknameController.dispose();
    _authKeyController.dispose();
    _adminApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a house name')),
      );
      return;
    }
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a nickname')),
      );
      return;
    }
    if (_authKeyController.text.trim().isEmpty ||
        _adminApiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your Tailscale auth key and admin API key'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await ref.read(onboardingNotifierProvider.notifier).bootstrapHost(
          displayName: _displayNameController.text.trim(),
          nickname: _nicknameController.text.trim(),
          tailscaleAuthKey: _authKeyController.text.trim(),
          tailscaleAdminApiKey: _adminApiKeyController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Name your house',
      subtitle:
          'Set up your house and connect Tailscale so roommates can join later.',
      showBack: true,
      backFallback: '/welcome',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(labelText: 'House name'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Your nickname',
                      hintText: 'Roommate-a3f2',
                      helperText: 'How roommates will see you in this house.',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _authKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Tailscale auth key',
                      hintText: 'tskey-auth-...',
                      helperText: 'Registers this device on your tailnet.',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _adminApiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Tailscale admin API key',
                      hintText: 'tskey-api-...',
                      helperText:
                          'Personal access token (tskey-api-…) from Tailscale '
                          'admin → Keys. Needs policy write + device tag access.',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create house'),
          ),
        ],
      ),
    );
  }
}
