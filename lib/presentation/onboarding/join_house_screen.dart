import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';

class JoinHouseScreen extends ConsumerStatefulWidget {
  const JoinHouseScreen({super.key, this.deepLinkPayload});

  final String? deepLinkPayload;

  @override
  ConsumerState<JoinHouseScreen> createState() => _JoinHouseScreenState();
}

class _JoinHouseScreenState extends ConsumerState<JoinHouseScreen> {
  final _inviteController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _authKeyController = TextEditingController();
  bool _loading = false;
  bool _scanning = false;
  JoinInvitePayload? _parsedInvite;

  @override
  void initState() {
    super.initState();
    if (widget.deepLinkPayload != null) {
      _tryParseInvite(widget.deepLinkPayload!);
    }
  }

  @override
  void dispose() {
    _inviteController.dispose();
    _nicknameController.dispose();
    _authKeyController.dispose();
    super.dispose();
  }

  void _tryParseInvite(String raw) {
    try {
      final codec = ref.read(joinInviteCodecProvider);
      final payload = raw.contains('://')
          ? codec.decode(raw)
          : codec.decodePayloadParam(raw);
      setState(() {
        _parsedInvite = payload;
        _inviteController.text = raw;
      });
    } on Object {
      // User can fix manually.
    }
  }

  Future<void> _submit() async {
    JoinInvitePayload? invite = _parsedInvite;
    if (invite == null) {
      try {
        final raw = _inviteController.text.trim();
        final codec = ref.read(joinInviteCodecProvider);
        invite = raw.contains('://')
            ? codec.decode(raw)
            : codec.decodePayloadParam(raw);
      } on Object catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid invite: $e')),
          );
        }
        return;
      }
    }

    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your nickname')),
      );
      return;
    }

    setState(() => _loading = true);
    await ref.read(onboardingNotifierProvider.notifier).bootstrapJoiner(
          invite: invite,
          nickname: _nicknameController.text.trim(),
          tailscaleAuthKey: _authKeyController.text.trim().isEmpty
              ? null
              : _authKeyController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    final state = ref.read(onboardingNotifierProvider);
    if (state.phase == LobbyPhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Join failed')),
      );
      return;
    }
    context.pushReplacement('/lobby');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Join a house',
      subtitle: 'Scan a QR code or paste the invite link from your roommate.',
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_scanning)
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          errorBuilder: (context, error) {
                            final message =
                                error.errorCode ==
                                        MobileScannerErrorCode.permissionDenied
                                    ? 'Camera access is needed to scan invite codes.'
                                    : 'Could not start the camera.';
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(message, textAlign: TextAlign.center),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () =>
                                          setState(() => _scanning = false),
                                      child: const Text('Go back'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onDetect: (capture) {
                            final barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              final value = barcode.rawValue;
                              if (value != null && value.isNotEmpty) {
                                setState(() => _scanning = false);
                                _tryParseInvite(value);
                                break;
                              }
                            }
                          },
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _scanning = true),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR code'),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _inviteController,
                    decoration: const InputDecoration(
                      labelText: 'Invite link or payload',
                    ),
                    maxLines: 3,
                    onChanged: (v) {
                      if (v.trim().isNotEmpty) {
                        _tryParseInvite(v.trim());
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nicknameController,
                    decoration:
                        const InputDecoration(labelText: 'Your nickname'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _authKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Tailscale auth key (optional for dev)',
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
                : const Text('Join house'),
          ),
        ],
      ),
    );
  }
}
