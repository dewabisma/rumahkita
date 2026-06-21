import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rumah/domain/generate_random_nickname.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_scaffold.dart';
import 'package:rumah/theme/app_spacing.dart';

class JoinScanScreen extends ConsumerStatefulWidget {
  const JoinScanScreen({super.key});

  @override
  ConsumerState<JoinScanScreen> createState() => _JoinScanScreenState();
}

class _JoinScanScreenState extends ConsumerState<JoinScanScreen> {
  final _nicknameController = TextEditingController();
  bool _scanning = true;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = generateRandomNickname();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String raw) async {
    if (_handling) {
      return;
    }
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a nickname')),
      );
      return;
    }
    setState(() => _handling = true);
    try {
      final codec = ref.read(joinInviteCodecProvider);
      final payload = raw.contains('://')
          ? codec.decode(raw)
          : codec.decodePayloadParam(raw);
      ref.read(onboardingNotifierProvider.notifier)
        ..setPendingJoinInvite(payload)
        ..setPendingNickname(_nicknameController.text.trim());
      if (mounted) {
        context.go('/join/connect');
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "That QR code isn't a valid house invite. "
              'Ask your roommate to show a fresh one.',
            ),
          ),
        );
        setState(() {
          _handling = false;
          _scanning = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;

    return OnboardingScaffold(
      title: 'Join a house',
      subtitle: 'Scan the QR code your roommate shared to join their house.',
      showBack: true,
      backFallback: '/welcome',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: 'Your nickname',
              hintText: 'Roommate-a3f2',
              helperText: 'How roommates will see you in this house.',
            ),
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: spacing.radiusCard),
          Expanded(
            child: _scanning
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(spacing.radiusCard),
                    child: MobileScanner(
                      errorBuilder: (context, error) {
                        final message =
                            error.errorCode ==
                                    MobileScannerErrorCode.permissionDenied
                                ? 'Camera access is needed to scan invite codes.'
                                : 'Could not start the camera.';
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(spacing.radiusCard),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(message, textAlign: TextAlign.center),
                                SizedBox(height: spacing.radiusSmall),
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
                        if (_handling) {
                          return;
                        }
                        for (final barcode in capture.barcodes) {
                          final value = barcode.rawValue;
                          if (value != null && value.isNotEmpty) {
                            setState(() => _scanning = false);
                            _handleScan(value);
                            break;
                          }
                        }
                      },
                    ),
                  )
                : Center(
                    child: _handling
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: () => setState(() => _scanning = true),
                            child: const Text('Scan again'),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
