import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';

class ConnectionStatusHeader extends ConsumerWidget {
  const ConnectionStatusHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const colors = AppColors.defaultTheme();
    final mesh = ref.watch(meshServiceProvider);
    final pending = ref.watch(pendingOpCountProvider).asData?.value ?? 0;

    final peerCount = mesh.peers.where((p) => p.online).length;
    final statusLabel = mesh.isUp
        ? 'Connected · $peerCount peer${peerCount == 1 ? '' : 's'}'
        : 'Connecting to your house network...';

    return Row(
      children: [
        Icon(
          mesh.isUp ? Icons.wifi : Icons.wifi_off,
          color: mesh.isUp ? colors.sproutGreen : colors.droopingLeafBrown,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
        ),
        if (pending > 0)
          Chip(
            label: Text('$pending pending'),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
