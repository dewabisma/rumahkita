import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_text_styles.dart';

class ConnectionStatusHeader extends ConsumerWidget {
  const ConnectionStatusHeader({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final mesh = ref.watch(meshServiceProvider);
    final pending = ref.watch(pendingOpCountProvider).asData?.value ?? 0;

    final peerCount = mesh.peers.where((p) => p.online).length;
    final statusLabel = mesh.isUp
        ? 'Connected · $peerCount peer${peerCount == 1 ? '' : 's'}'
        : compact
        ? 'Connecting...'
        : 'Connecting to your house network...';

    final labelStyle = (compact ? text.caption : text.bodySmall)?.copyWith(
      color: colors.textSecondary,
    );

    return Row(
      children: [
        Icon(
          mesh.isUp ? Icons.wifi : Icons.wifi_off,
          color: mesh.isUp ? colors.sproutGreen : colors.droopingLeafBrown,
          size: compact ? 16 : 20,
        ),
        SizedBox(width: compact ? 6 : 8),
        Expanded(
          child: Text(
            statusLabel,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (pending > 0)
          compact
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '$pending',
                    style: labelStyle,
                  ),
                )
              : Chip(
                  label: Text('$pending pending'),
                  visualDensity: VisualDensity.compact,
                ),
      ],
    );
  }
}
