import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/entities/house_privilege.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/ceremony/widgets/ceremony_add_sheets.dart';
import 'package:rumah/presentation/ceremony/widgets/ceremony_assignee_sheet.dart';
import 'package:rumah/presentation/ceremony/widgets/ceremony_description_field.dart';
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
  final Map<String, int> _taskPointsBaseline = {};
  final Map<String, String> _taskTitleBaseline = {};
  final Map<String, String> _taskDescriptionBaseline = {};
  final Map<String, String> _taskAssigneeBaseline = {};
  final Map<String, int> _privilegeCostBaseline = {};
  final Map<String, String> _privilegeNameBaseline = {};
  final Map<String, String> _privilegeDescriptionBaseline = {};

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
        centerTitle: true,
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
                final privilegesAsync =
                    ref.watch(privilegesForCycleProvider(cycle.cycleId));
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
                          CeremonySectionHeader(
                            title: 'Chores',
                            addTooltip: 'Add chore',
                            onAdd: () => showAddChoreSheet(
                              context,
                              houseId: houseId,
                              cycleId: cycle.cycleId,
                            ),
                          ),
                          const SizedBox(height: 8),
                          tasksAsync.when(
                            data: (tasks) {
                              _seedTaskBaselines(tasks);
                              final housemates =
                                  matesAsync.asData?.value ?? const <Housemate>[];
                              return Column(
                                children: [
                                  if (tasks.isEmpty)
                                    const CeremonySectionEmptyState(
                                      icon: Icons.checklist_outlined,
                                      message:
                                          'No chores yet — tap + when you\'re '
                                          'ready to add the first one together.',
                                    )
                                  else
                                    ...tasks.map(
                                      (task) => _TaskCard(
                                        task: task,
                                        housemates: housemates,
                                        colors: colors,
                                        text: text,
                                        spacing: spacing,
                                        showDelta: _hasTaskDelta(task),
                                        previousPoints:
                                            _taskPointsBaseline[task.taskId],
                                        previousTitle:
                                            _taskTitleBaseline[task.taskId],
                                        previousDescription:
                                            _taskDescriptionBaseline[task.taskId],
                                        previousAssignee:
                                            _taskAssigneeBaseline[task.taskId],
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
                                        onTitleChanged: (title) =>
                                            _updateTitle(
                                          houseId: houseId,
                                          task: task,
                                          title: title,
                                        ),
                                        onDescriptionChanged: (description) =>
                                            _updateDescription(
                                          houseId: houseId,
                                          task: task,
                                          description: description,
                                        ),
                                        onAssigneeChanged: (assigneeId) =>
                                            _updateAssignee(
                                          houseId: houseId,
                                          task: task,
                                          assignedToMemberId: assigneeId,
                                        ),
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
                          CeremonySectionHeader(
                            title: 'Privileges',
                            addTooltip: 'Add perk',
                            onAdd: () => showAddPrivilegeSheet(
                              context,
                              houseId: houseId,
                              cycleId: cycle.cycleId,
                            ),
                          ),
                          const SizedBox(height: 8),
                          privilegesAsync.when(
                            data: (privileges) {
                              _seedPrivilegeBaselines(privileges);
                              return Column(
                                children: [
                                  if (privileges.isEmpty)
                                    const CeremonySectionEmptyState(
                                      icon: Icons.emoji_events_outlined,
                                      message:
                                          'No perks yet — tap + to dream up '
                                          'something worth earning points for.',
                                    )
                                  else
                                    ...privileges.map(
                                      (privilege) => _PrivilegeCard(
                                      privilege: privilege,
                                      colors: colors,
                                      text: text,
                                      spacing: spacing,
                                      showDelta: _hasPrivilegeDelta(privilege),
                                      previousCost:
                                          _privilegeCostBaseline[privilege.privilegeId],
                                      previousName:
                                          _privilegeNameBaseline[privilege.privilegeId],
                                      previousDescription:
                                          _privilegeDescriptionBaseline[
                                              privilege.privilegeId],
                                      onArchive: () => _archivePrivilege(
                                        houseId: houseId,
                                        privilege: privilege,
                                      ),
                                      onCostChanged: (cost) => _updatePrivilegeCost(
                                        houseId: houseId,
                                        privilege: privilege,
                                        pointCost: cost,
                                      ),
                                      onNameChanged: (name) => _updatePrivilegeName(
                                        houseId: houseId,
                                        privilege: privilege,
                                        name: name,
                                      ),
                                      onDescriptionChanged: (description) =>
                                          _updatePrivilegeDescription(
                                        houseId: houseId,
                                        privilege: privilege,
                                        description: description,
                                      ),
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
      _taskDescriptionBaseline.putIfAbsent(
        task.taskId,
        () => task.description,
      );
      _taskAssigneeBaseline.putIfAbsent(
        task.taskId,
        () => task.assignedToMemberId,
      );
    }
  }

  bool _hasTaskDelta(Task task) {
    final prevPoints = _taskPointsBaseline[task.taskId];
    final prevTitle = _taskTitleBaseline[task.taskId];
    final prevDescription = _taskDescriptionBaseline[task.taskId];
    final prevAssignee = _taskAssigneeBaseline[task.taskId];
    if (prevPoints != null && prevPoints != task.negotiatedPoints) {
      return true;
    }
    if (prevTitle != null && prevTitle != task.title) {
      return true;
    }
    if (prevDescription != null && prevDescription != task.description) {
      return true;
    }
    if (prevAssignee != null && prevAssignee != task.assignedToMemberId) {
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
    _taskDescriptionBaseline.putIfAbsent(
      task.taskId,
      () => task.description,
    );
    _taskAssigneeBaseline.putIfAbsent(
      task.taskId,
      () => task.assignedToMemberId,
    );
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

  Future<void> _updateDescription({
    required String houseId,
    required Task task,
    required String description,
  }) async {
    _captureBaseline(task);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updateTaskDescription(
          houseId: houseId,
          taskId: task.taskId,
          description: description,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _updateAssignee({
    required String houseId,
    required Task task,
    required String assignedToMemberId,
  }) async {
    _captureBaseline(task);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updateTaskAssignee(
          houseId: houseId,
          taskId: task.taskId,
          assignedToMemberId: assignedToMemberId,
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

  void _seedPrivilegeBaselines(List<HousePrivilege> privileges) {
    for (final privilege in privileges) {
      _privilegeCostBaseline.putIfAbsent(
        privilege.privilegeId,
        () => privilege.pointCost,
      );
      _privilegeNameBaseline.putIfAbsent(
        privilege.privilegeId,
        () => privilege.name,
      );
      _privilegeDescriptionBaseline.putIfAbsent(
        privilege.privilegeId,
        () => privilege.description,
      );
    }
  }

  bool _hasPrivilegeDelta(HousePrivilege privilege) {
    final prevCost = _privilegeCostBaseline[privilege.privilegeId];
    final prevName = _privilegeNameBaseline[privilege.privilegeId];
    final prevDescription =
        _privilegeDescriptionBaseline[privilege.privilegeId];
    if (prevCost != null && prevCost != privilege.pointCost) {
      return true;
    }
    if (prevName != null && prevName != privilege.name) {
      return true;
    }
    if (prevDescription != null && prevDescription != privilege.description) {
      return true;
    }
    return false;
  }

  void _capturePrivilegeBaseline(HousePrivilege privilege) {
    _privilegeCostBaseline.putIfAbsent(
      privilege.privilegeId,
      () => privilege.pointCost,
    );
    _privilegeNameBaseline.putIfAbsent(
      privilege.privilegeId,
      () => privilege.name,
    );
    _privilegeDescriptionBaseline.putIfAbsent(
      privilege.privilegeId,
      () => privilege.description,
    );
  }

  Future<void> _updatePrivilegeName({
    required String houseId,
    required HousePrivilege privilege,
    required String name,
  }) async {
    _capturePrivilegeBaseline(privilege);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updatePrivilegeName(
          houseId: houseId,
          privilegeId: privilege.privilegeId,
          name: name,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _updatePrivilegeDescription({
    required String houseId,
    required HousePrivilege privilege,
    required String description,
  }) async {
    _capturePrivilegeBaseline(privilege);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updatePrivilegeDescription(
          houseId: houseId,
          privilegeId: privilege.privilegeId,
          description: description,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _updatePrivilegeCost({
    required String houseId,
    required HousePrivilege privilege,
    required int pointCost,
  }) async {
    _capturePrivilegeBaseline(privilege);
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).updatePrivilegePointCost(
          houseId: houseId,
          privilegeId: privilege.privilegeId,
          pointCost: pointCost,
          actorMemberId: member.memberId,
        );
  }

  Future<void> _archivePrivilege({
    required String houseId,
    required HousePrivilege privilege,
  }) async {
    final member = await ref.read(localMemberProvider.future);
    if (member == null) {
      return;
    }
    await ref.read(ceremonyRepositoryProvider).archivePrivilege(
          houseId: houseId,
          privilegeId: privilege.privilegeId,
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
      _taskDescriptionBaseline.clear();
      _taskAssigneeBaseline.clear();
      _privilegeCostBaseline.clear();
      _privilegeNameBaseline.clear();
      _privilegeDescriptionBaseline.clear();
    });
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.housemates,
    required this.colors,
    required this.text,
    required this.spacing,
    required this.showDelta,
    required this.previousPoints,
    required this.previousTitle,
    required this.previousDescription,
    required this.previousAssignee,
    required this.onArchive,
    required this.onPointsChanged,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onAssigneeChanged,
  });

  final Task task;
  final List<Housemate> housemates;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;
  final bool showDelta;
  final int? previousPoints;
  final String? previousTitle;
  final String? previousDescription;
  final String? previousAssignee;
  final VoidCallback onArchive;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onAssigneeChanged;

  Future<void> _pickAssignee(BuildContext context) async {
    final selected = await showCeremonyAssigneeSheet(
      context,
      housemates: housemates,
      currentMemberId: task.assignedToMemberId,
    );
    if (selected != null) {
      onAssigneeChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deltaText = _deltaLabel();
    final assigneeText = assigneeLabel(
      assignedToMemberId: task.assignedToMemberId,
      housemates: housemates,
    );

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
            CeremonyDescriptionField(
              initialValue: task.description,
              style: text.body,
              onSubmitted: onDescriptionChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${task.negotiatedPoints}',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: text.body,
                    decoration: const InputDecoration(
                      labelText: 'Points worth',
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
                  tooltip: 'Remove chore',
                  onPressed: onArchive,
                  icon: Icon(Icons.delete_outline, color: colors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _pickAssignee(context),
              icon: const Icon(Icons.person_outline),
              label: Text('Assigned to: $assigneeText'),
            ),
            if (deltaText != null) ...[
              SizedBox(height: spacing.radiusSmall),
              Text(
                deltaText,
                style: text.bodySmall?.copyWith(color: colors.textOnSunnyButter),
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
    if (previousDescription != null &&
        previousDescription != task.description) {
      return 'Description updated';
    }
    if (previousAssignee != null &&
        previousAssignee != task.assignedToMemberId) {
      return 'Assignment updated';
    }
    return null;
  }
}

class _PrivilegeCard extends StatelessWidget {
  const _PrivilegeCard({
    required this.privilege,
    required this.colors,
    required this.text,
    required this.spacing,
    required this.showDelta,
    required this.previousCost,
    required this.previousName,
    required this.previousDescription,
    required this.onArchive,
    required this.onCostChanged,
    required this.onNameChanged,
    required this.onDescriptionChanged,
  });

  final HousePrivilege privilege;
  final AppColors colors;
  final AppTextTheme text;
  final AppSizeTheme spacing;
  final bool showDelta;
  final int? previousCost;
  final String? previousName;
  final String? previousDescription;
  final VoidCallback onArchive;
  final ValueChanged<int> onCostChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;

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
              initialValue: privilege.name,
              style: text.body,
              decoration: const InputDecoration(
                labelText: 'Perk name',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: onNameChanged,
            ),
            const SizedBox(height: 8),
            CeremonyDescriptionField(
              initialValue: privilege.description,
              style: text.body,
              onSubmitted: onDescriptionChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${privilege.pointCost}',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: text.body,
                    decoration: const InputDecoration(
                      labelText: 'Point cost',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (v) {
                      final parsed = int.tryParse(v);
                      if (parsed != null) {
                        onCostChanged(parsed);
                      }
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Remove perk',
                  onPressed: onArchive,
                  icon: Icon(Icons.delete_outline, color: colors.textMuted),
                ),
              ],
            ),
            if (deltaText != null) ...[
              SizedBox(height: spacing.radiusSmall),
              Text(
                deltaText,
                style: text.bodySmall?.copyWith(color: colors.textOnSunnyButter),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _deltaLabel() {
    if (previousCost != null && previousCost != privilege.pointCost) {
      return 'Cost updated: $previousCost → ${privilege.pointCost}';
    }
    if (previousName != null && previousName != privilege.name) {
      return 'Name updated: $previousName → ${privilege.name}';
    }
    if (previousDescription != null &&
        previousDescription != privilege.description) {
      return 'Description updated';
    }
    return null;
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
