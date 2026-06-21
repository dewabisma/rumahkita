import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/presentation/ceremony/widgets/ceremony_assignee_sheet.dart';
import 'package:rumah/presentation/ceremony/widgets/ceremony_description_field.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class CeremonySectionHeader extends StatelessWidget {
  const CeremonySectionHeader({
    super.key,
    required this.title,
    required this.addTooltip,
    required this.onAdd,
  });

  final String title;
  final String addTooltip;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final text = context.themeText;

    return Row(
      children: [
        Expanded(child: Text(title, style: text.sectionTitle)),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: addTooltip,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class CeremonySectionEmptyState extends StatelessWidget {
  const CeremonySectionEmptyState({
    super.key,
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.radiusCard,
        vertical: spacing.radiusLarge,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(spacing.radiusCard),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: colors.textMuted),
          SizedBox(height: spacing.radiusSmall),
          Text(
            message,
            style: text.body?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Future<void> showAddChoreSheet(
  BuildContext context, {
  required String houseId,
  required String cycleId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => _AddChoreSheet(
      houseId: houseId,
      cycleId: cycleId,
    ),
  );
}

Future<void> showAddPrivilegeSheet(
  BuildContext context, {
  required String houseId,
  required String cycleId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => _AddPrivilegeSheet(
      houseId: houseId,
      cycleId: cycleId,
    ),
  );
}

class _AddChoreSheet extends ConsumerStatefulWidget {
  const _AddChoreSheet({
    required this.houseId,
    required this.cycleId,
  });

  final String houseId;
  final String cycleId;

  @override
  ConsumerState<_AddChoreSheet> createState() => _AddChoreSheetState();
}

class _AddChoreSheetState extends ConsumerState<_AddChoreSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  String? _assignedToMemberId;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickAssignee() async {
    final mates = await ref.read(housematesProvider(widget.houseId).future);
    if (!mounted) {
      return;
    }
    final selected = await showCeremonyAssigneeSheet(
      context,
      housemates: mates,
      currentMemberId: _assignedToMemberId,
    );
    if (selected != null && mounted) {
      setState(() => _assignedToMemberId = selected.isEmpty ? null : selected);
    }
  }

  Future<void> _add() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final points = int.tryParse(_pointsController.text) ?? 10;
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a chore title')),
      );
      return;
    }

    final member = await ref.read(localMemberProvider.future);
    if (member == null || !mounted) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(ceremonyRepositoryProvider).addTask(
            houseId: widget.houseId,
            cycleId: widget.cycleId,
            title: title,
            description: description,
            points: points,
            assignedToMemberId: _assignedToMemberId ?? '',
            actorMemberId: member.memberId,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final matesAsync = ref.watch(housematesProvider(widget.houseId));
    final assigneeLabelText = matesAsync.maybeWhen(
      data: (mates) => assigneeLabel(
        assignedToMemberId: _assignedToMemberId,
        housemates: mates,
      ),
      orElse: () => 'Unassigned',
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.radiusCard,
        0,
        spacing.radiusCard,
        spacing.radiusCard + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add chore', style: text.sectionTitle),
            SizedBox(height: spacing.radiusSmall),
            Text(
              'Describe the chore, set its point value, and assign it if you '
              'already know who will take it.',
              style: text.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.radiusCard),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Chore title',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            SizedBox(height: spacing.radiusSmall),
            CeremonyDescriptionField(
              controller: _descriptionController,
              hintText: 'What makes this chore harder or easier?',
            ),
            SizedBox(height: spacing.radiusSmall),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Points worth',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: spacing.radiusSmall),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickAssignee,
              icon: const Icon(Icons.person_outline),
              label: Text('Assigned to: $assigneeLabelText'),
            ),
            SizedBox(height: spacing.radiusCard),
            FilledButton(
              onPressed: _saving ? null : _add,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add chore'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPrivilegeSheet extends ConsumerStatefulWidget {
  const _AddPrivilegeSheet({
    required this.houseId,
    required this.cycleId,
  });

  final String houseId;
  final String cycleId;

  @override
  ConsumerState<_AddPrivilegeSheet> createState() => _AddPrivilegeSheetState();
}

class _AddPrivilegeSheetState extends ConsumerState<_AddPrivilegeSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController(text: '20');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final pointCost = int.tryParse(_costController.text) ?? 20;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a perk name')),
      );
      return;
    }

    final member = await ref.read(localMemberProvider.future);
    if (member == null || !mounted) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(ceremonyRepositoryProvider).addPrivilege(
            houseId: widget.houseId,
            cycleId: widget.cycleId,
            name: name,
            description: description,
            pointCost: pointCost,
            actorMemberId: member.memberId,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.radiusCard,
        0,
        spacing.radiusCard,
        spacing.radiusCard + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add perk', style: text.sectionTitle),
            SizedBox(height: spacing.radiusSmall),
            Text(
              'Describe the perk and how many points it costs to redeem.',
              style: text.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.radiusCard),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Perk name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            SizedBox(height: spacing.radiusSmall),
            CeremonyDescriptionField(
              controller: _descriptionController,
              hintText: 'What do roommates get when they redeem this?',
            ),
            SizedBox(height: spacing.radiusSmall),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Point cost',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saving ? null : _add(),
            ),
            SizedBox(height: spacing.radiusCard),
            FilledButton(
              onPressed: _saving ? null : _add,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add perk'),
            ),
          ],
        ),
      ),
    );
  }
}
