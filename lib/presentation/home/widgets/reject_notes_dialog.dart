import 'package:flutter/material.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class RejectNotesDialog extends StatefulWidget {
  const RejectNotesDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String?>(
      context: context,
      builder: (context) => const RejectNotesDialog(),
    );
  }

  @override
  State<RejectNotesDialog> createState() => _RejectNotesDialogState();
}

class _RejectNotesDialogState extends State<RejectNotesDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;

    return AlertDialog(
      backgroundColor: colors.surfaceCard,
      title: Text('Send back with a note?', style: text.sectionTitle),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        style: text.body,
        decoration: InputDecoration(
          hintText: 'Optional — what needs a little more love?',
          hintStyle: text.body?.copyWith(color: colors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(spacing.radiusButton),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(spacing.radiusButton),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(spacing.radiusButton),
            borderSide: BorderSide(color: colors.sproutGreen),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: text.label),
        ),
        FilledButton(
          onPressed: () {
            final notes = _controller.text.trim();
            Navigator.of(context).pop(notes.isEmpty ? null : notes);
          },
          child: Text('Send back', style: text.label),
        ),
      ],
    );
  }
}
