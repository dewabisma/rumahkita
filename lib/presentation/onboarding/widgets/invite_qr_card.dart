import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class InviteQrCard extends StatelessWidget {
  const InviteQrCard({super.key, required this.inviteLink});

  final String inviteLink;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;

    return Card(
      color: colors.surfaceElevated,
      child: Padding(
        padding: EdgeInsets.all(spacing.radiusCard),
        child: Column(
          children: [
            QrImageView(
              data: inviteLink,
              size: 180,
              backgroundColor: colors.surface,
            ),
            SizedBox(height: spacing.radiusSmall),
            Text('Scan to join', style: text.sectionTitle),
          ],
        ),
      ),
    );
  }
}
