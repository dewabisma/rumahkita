import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/entities/privilege_template.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/presentation/onboarding/widgets/connection_status_header.dart';
import 'package:rumah/presentation/onboarding/widgets/onboarding_settings_action_sheet.dart';
import 'package:rumah/theme/app_colors.dart';
import 'package:rumah/theme/app_spacing.dart';
import 'package:rumah/theme/app_text_styles.dart';

class CeremonyScreen extends ConsumerStatefulWidget {
  const CeremonyScreen({super.key});

  @override
  ConsumerState<CeremonyScreen> createState() => _CeremonyScreenState();
}

class _CeremonyScreenState extends ConsumerState<CeremonyScreen> {
  final _taskTitleController = TextEditingController();
  final _taskPointsController = TextEditingController(text: '10');
  final Map<String, int> _taskPointsBaseline = {};
  final Map<String, String> _taskTitleBaseline = {};

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = context.themeText;
    final spacing = context.themeSpacing;
    final houseIdAsync = ref.watch(activeHouseIdProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.push('/lobby');
            }
          },
        ),
        automaticallyImplyLeading: false,
        title: Text('Ceremony', style: text.sectionTitle),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => showOnboardingSettingsActionSheet(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: houseIdAsync.when(
          data: (houseId) {
            if (houseId == null) {
              return const Center(child: Text('No active house'));
            }
            final cycleAsync = ref.watch(draftingCycleProvider(houseId));
            return cycleAsync.when(
              data: (cycle) {
                if (cycle == null) {
                  return const Center(child: Text('No drafting cycle'));
                }
                final tasksAsync =
                    ref.watch(tasksForCycleProvider(cycle.cycleId));
                final templatesAsync =
                    ref.watch(privilegeTemplatesProvider(houseId));
                final signoffAsync =
                    ref.watch(ceremonySignoffStatusProvider(cycle.cycleId));
                final matesAsync = ref.watch(housematesProvider(houseId));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ConnectionStatusHeader(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(spacing.radiusCard),
                        children: [
                          Text(
                            'Draft your house rules together',
                            style: text.headline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add chores, tune privileges, then everyone accepts.',
                            style: text.body?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: spacing.radiusCard),
                          Text('Chores', style: text.sectionTitle),
                          const SizedBox(height: 8),
                          tasksAsync.when(
                            data: (tasks) {
                              _seedTaskBaselines(tasks);
                              return Column(
                                children: [
                                  ...tasks.map(
                                    (task) => _TaskCard(
                                      task: task,
                                      colors: colors,
                                      text: text,
                                      spacing: spacing,
                                      showDelta: _hasTaskDelta(task),
                                      previousPoints:
                                          _taskPointsBaseline[task.taskId],
                                      previousTitle:
                                          _taskTitleBaseline[task.taskId],
                                      onArchive: () => _archiveTask(
                                        houseId: houseId,
                                        task: task,
                                      ),
                                      onPointsChanged: (points) =>
                                          _updatePoints(
                                        houseId: houseId,
                                        task: task,
                                        points: points,
                                      ),
                                      onTitleChanged: (title) => _updateTitle(
                                        houseId: houseId,
                                        task: task,
                                        title: title,
                                      ),
                                    ),
                                  ),
                                  _AddTaskRow(
                                    titleController: _taskTitleController,
                                    pointsController: _taskPointsController,
                                    spacing: spacing,
                                    onAdd: () => _addTask(
                                      houseId: houseId,
                                      cycleId: cycle.cycleId,
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          SizedBox(height: spacing.radiusCard),
                          Text('Privileges', style: text.sectionTitle),
                          const SizedBox(height: 8),
                          templatesAsync.when(
                            data: (templates) => Column(
                              children: templates.values
                                  .map(
                                    (template) => _PrivilegeCard(
                                      template: template,
                                      colors: colors,
                                      text: text,
                                      spacing: spacing,
                                      onChanged: (updated) =>
                                          _updatePrivilege(
                                        houseId: houseId,
                                        templates: templates,
                                        updated: updated,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          SizedBox(height: spacing.radiusCard),
                          Text('Accept status', style: text.sectionTitle),
                          const SizedBox(height: 8),
                          matesAsync.when(
                            data: (mates) => signoffAsync.when(
                              data: (signoff) => Wrap(
                                spacing: spacing.radiusSmall,
                                runSpacing: spacing.radiusSmall,
                                children: mates
                                    .where(
                                      (m) =>
                                          m.memberStatus == MemberStatus.active,
                                    )
                                    .map(
                                      (mate) => _SignoffChip(
                                        nickname: mate.nickname,
                                        accepted: signoff
                                                .acceptedByMemberId[
                                            mate.memberId] ??
                                            false,
                                        colors: colors,
                                        text: text,
                                      ),
                                    )
                                    .toList(),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (e, _) => Text('Error: $e'),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          if (signoffAsync.asData?.value.rulesVersionStale ==
                              true) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Rules changed — everyone needs to accept again.',
                              style: text.bodySmall?.copyWith(
                                color: colors.active,
                              ),
                            ),
                          ],
                          SizedBox(height: spacing.radiusLarge),
                          signoffAsync.when(
                            data: (signoff) {
                              final localMember =
                                  ref.watch(localMemberProvider).asData?.value;
                              final localAccepted = signoff.localAccepted;
                              return FilledButton(
                                onPressed: localMember == null || localAccepted
                                    ? null
                                    : () => _acceptRules(
                                          houseId: houseId,
                                          cycleId: cycle.cycleId,
                                          memberId: localMember.memberId,
                                        ),
                                child: Text(
                                  localAccepted
                                      ? 'You accepted'
                                      : 'Accept Rules',
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, _) => Text('Error: $e'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _seedTaskBaselines(List<Task> tasks) {
    for (final task in tasks) {
      _taskPointsBaseline.putIfAbsent(
        task.taskId,
        () => task.negotiatedPoints,
      );
      _taskTitleBaseline.putIfAbsent(task.taskId, () => task.title);
    }
  }

  bool _hasTaskDelta(Task task) {
    final prevPoints = _taskPointsBaseline[task.taskId];
    final prevTitle = _taskTitleBaseline[task.taskId];
    if (prevPoints != null && prevPoints != task.negotiatedPoints) {
      return true;
    }
    if (prevTitle != null && prevTitle != task.title) {
      return true;
    }
    return false;
  }

  void _captureBaseline(Task task) {
    _taskPointsBaseline.putIfAbsent(
      task.taskId,
      () => task.negotiatedPoints,
    );
    _taskTitleBaseline.putIfAbsent(task.taskId, () => task.title);
  }

  Future<void> _addTask({
    required String houseId,
    required String cycleId,
  }) async {
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    final title = _taskTitleController.text.trim();
    final points = int.tryParse(_taskPointsController.text) ?? 10;
    if (title.isEmpty) {
      return;
    }
    final repo = ref.read(ceremonyRepositoryProvider);
    await repo.addTask(
      houseId: houseId,
      cycleId: cycleId,
      title: title,
      points: points,
      actorMemberId: member.memberId,
    );
    _taskTitleController.clear();
    _taskPointsController.text = '10';
  }

  Future<void> _updateTitle({
    required String houseId,
    required Task task,
    required String title,
  }) async {
    _captureBaseline(task);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updateTaskTitle(
          houseId: houseId,
          taskId: task.taskId,
          title: title,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _updatePoints({
    required String houseId,
    required Task task,
    required int points,
  }) async {
    _captureBaseline(task);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updateTaskPoints(
          houseId: houseId,
          taskId: task.taskId,
          points: points,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _archiveTask({
    required String houseId,
    required Task task,
  }) async {
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).archiveTask(
          houseId: houseId,
          taskId: task.taskId,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _updatePrivilege({
    required String houseId,
    required Map<String, PrivilegeTemplate> templates,
    required PrivilegeTemplate updated,
  }) async {
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    final next = Map<String, PrivilegeTemplate>.from(templates);
    next[updated.id] = updated;
    await ref.read(ceremonyRepositoryProvider).updatePrivilegeTemplates(
          houseId: houseId,
          templates: next,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _acceptRules({
    required String houseId,
    required String cycleId,
    required String memberId,
  }) async {
    await ref.read(ceremonyRepositoryProvider).acceptRules(
          houseId: houseId,
          cycleId: cycleId,
          memberId: memberId,
        );
    setState(() {
      _taskPointsBaseline.clear();
      _taskTitleBaseline.clear();
    });
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.colors,
    required this.text,
    required this.spacing,
    required this.showDelta,
    required this.previousPoints,
    required this.previousTitle,
    required this.onArchive,
    required this.onPointsChanged,
    required this.onTitleChanged,
  });

  final Task task;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;
  final bool showDelta;
  final int? previousPoints;
  final String? previousTitle;
  final VoidCallback onArchive;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<String> onTitleChanged;

  @override
  Widget build(BuildContext context) {
    final deltaText = _deltaLabel();
    return Card(
      color: showDelta ? colors.activeSurface : colors.surfaceCard,
      margin: EdgeInsets.only(bottom: spacing.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(spacing.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: task.title,
              style: text.body,
              decoration: const InputDecoration(
                labelText: 'Chore title',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: onTitleChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${task.negotiatedPoints}',
                    keyboardType: TextInputType.number,
                    style: text.body,
                    decoration: const InputDecoration(
                      labelText: 'Points',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (v) {
                      final parsed = int.tryParse(v);
                      if (parsed != null) {
                        onPointsChanged(parsed);
                      }
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Archive chore',
                  onPressed: onArchive,
                  icon: Icon(Icons.archive_outlined, color: colors.textMuted),
                ),
              ],
            ),
            if (deltaText != null) ...[
              SizedBox(height: spacing.radiusSmall),
              Text(
                deltaText,
                style: text.bodySmall?.copyWith(color: colors.active),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _deltaLabel() {
    if (previousPoints != null && previousPoints != task.negotiatedPoints) {
      return 'Points updated: $previousPoints → ${task.negotiatedPoints}';
    }
    if (previousTitle != null && previousTitle != task.title) {
      return 'Title updated: $previousTitle → ${task.title}';
    }
    return null;
  }
}

class _AddTaskRow extends StatelessWidget {
  const _AddTaskRow({
    required this.titleController,
    required this.pointsController,
    required this.spacing,
    required this.onAdd,
  });

  final TextEditingController titleController;
  final TextEditingController pointsController;
  final AppSizeTheme spacing;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'New chore',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: spacing.radiusSmall),
        SizedBox(
          width: 72,
          child: TextField(
            controller: pointsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pts',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle)),
      ],
    );
  }
}

class _PrivilegeCard extends StatefulWidget {
  const _PrivilegeCard({
    required this.template,
    required this.colors,
    required this.text,
    required this.spacing,
    required this.onChanged,
  });

  final PrivilegeTemplate template;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;
  final ValueChanged<PrivilegeTemplate> onChanged;

  @override
  State<_PrivilegeCard> createState() => _PrivilegeCardState();
}

class _PrivilegeCardState extends State<_PrivilegeCard> {
  late double _threshold;

  @override
  void initState() {
    super.initState();
    _threshold = widget.template.unlockThreshold.toDouble();
  }

  @override
  void didUpdateWidget(_PrivilegeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template.unlockThreshold != widget.template.unlockThreshold) {
      _threshold = widget.template.unlockThreshold.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    return Card(
      color: widget.colors.surfaceCard,
      margin: EdgeInsets.only(bottom: widget.spacing.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(widget.spacing.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(template.name, style: widget.text.sectionTitle),
                ),
                Switch(
                  value: template.enabled,
                  onChanged: (v) =>
                      widget.onChanged(template.copyWith(enabled: v)),
                ),
              ],
            ),
            Text(
              template.description,
              style: widget.text.bodySmall?.copyWith(
                color: widget.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Threshold', style: widget.text.label),
                SizedBox(width: widget.spacing.radiusSmall),
                Expanded(
                  child: Slider(
                    value: _threshold,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${_threshold.round()}',
                    onChanged: template.enabled
                        ? (v) => setState(() => _threshold = v)
                        : null,
                    onChangeEnd: template.enabled
                        ? (v) => widget.onChanged(
                              template.copyWith(unlockThreshold: v.round()),
                            )
                        : null,
                  ),
                ),
                Text('${_threshold.round()}', style: widget.text.label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignoffChip extends StatelessWidget {
  const _SignoffChip({
    required this.nickname,
    required this.accepted,
    required this.colors,
    required this.text,
  });

  final String nickname;
  final bool accepted;
  final AppColors colors;
  final AppTextTheme text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        accepted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: accepted ? colors.success : colors.textMuted,
        size: 18,
      ),
      label: Text(nickname, style: text.bodySmall),
      backgroundColor: accepted ? colors.successSurface : colors.surfaceCard,
    );
  }
}
