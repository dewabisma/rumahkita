import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/presentation/removal/removal_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class RemovalAuditSection extends ConsumerWidget {
  const RemovalAuditSection({super.key, required this.proposalId});

  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final audits = ref.watch(removalAuditProvider(proposalId));

    return audits.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }
        final sorted = [...entries]
          ..sort((a, b) => _compareHlc(a.hlc, b.hlc));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit log', style: text.sectionTitle),
            SizedBox(height: spacing.radiusSmall),
            ...sorted.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: spacing.radiusSmall),
                child: Text(
                  '${entry.action} — ${entry.actorMemberId}',
                  style: text.body?.copyWith(color: colors.textSecondary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _compareHlc(List<int> a, List<int> b) {
    final len = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final cmp = a[i].compareTo(b[i]);
      if (cmp != 0) {
        return cmp;
      }
    }
    return a.length.compareTo(b.length);
  }
}
