import 'package:flutter/material.dart';
import 'package:rumah/theme/app_text_styles.dart';

/// Multiline description input shared by ceremony chores and perks.
class CeremonyDescriptionField extends StatefulWidget {
  const CeremonyDescriptionField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.style,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
  }) : assert(
          controller != null || initialValue != null,
          'Provide controller or initialValue',
        );

  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final TextStyle? style;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;

  static const int minLines = 3;
  static const int maxLines = 6;

  @override
  State<CeremonyDescriptionField> createState() =>
      _CeremonyDescriptionFieldState();
}

class _CeremonyDescriptionFieldState extends State<CeremonyDescriptionField> {
  TextEditingController? _ownedController;
  late final FocusNode _focusNode;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: widget.initialValue ?? '');
    }
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(CeremonyDescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null &&
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && widget.onSubmitted != null) {
      widget.onSubmitted!(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = context.themeText;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.style ?? text.body,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: widget.hintText,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
      minLines: CeremonyDescriptionField.minLines,
      maxLines: CeremonyDescriptionField.maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: widget.textInputAction ?? TextInputAction.newline,
      autofocus: widget.autofocus,
    );
  }
}
