import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _loading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _nicknameController.dispose();
    _authKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_displayNameController.text.trim().isEmpty ||
        _nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in house name and nickname')),
      );
      return;
    }
    setState(() => _loading = true);
    await ref.read(onboardingNotifierProvider.notifier).bootstrapHost(
          displayName: _displayNameController.text.trim(),
          nickname: _nicknameController.text.trim(),
          tailscaleAuthKey: _authKeyController.text.trim().isEmpty
              ? null
              : _authKeyController.text.trim(),
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
      subtitle: 'Give your shared home a cozy name and pick your nickname.',
      showBack: true,
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
            decoration: const InputDecoration(labelText: 'Your nickname'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _authKeyController,
            decoration: const InputDecoration(
              labelText: 'Tailscale auth key (optional for dev)',
              hintText: 'tskey-auth-...',
            ),
            obscureText: true,
          ),
          const Spacer(),
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
