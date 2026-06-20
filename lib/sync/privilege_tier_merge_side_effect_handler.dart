import 'dart:convert';

import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/entities/privilege_template.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/privilege_tier_evaluator.dart';
import 'package:rumah/sync/privilege_tier_ids.dart';
import 'package:rumah/sync/sync_operation.dart';

/// Emits privilege tier crossing audits when member scores change.
class PrivilegeTierMergeSideEffectHandler implements MergeSideEffectHandler {
  PrivilegeTierMergeSideEffectHandler(this._db);

  final AppDatabase _db;
  SyncWriteCoordinator? _sync;

  void bindSync(SyncWriteCoordinator sync) => _sync = sync;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      if (effect is ScoreChanged) {
        await _handleScoreChanged(effect);
      }
    }
  }

  Future<void> _handleScoreChanged(ScoreChanged effect) async {
    final sync = _sync;
    if (sync == null) {
      return;
    }
    final templates = await _loadTemplates(effect.houseId);
    final crossings = detectCrossings(
      templates: templates,
      oldScore: effect.oldScore,
      newScore: effect.newScore,
    );
    if (crossings.isEmpty) {
      return;
    }

    final ops = <SyncOperation>[];
    for (final crossing in crossings) {
      final logId = crossingLogId(
        houseId: effect.houseId,
        memberId: effect.memberId,
        templateId: crossing.template.id,
        direction: crossing.direction,
        triggeringEventId: effect.triggeringEventId,
      );
      final justification = jsonEncode({
        'member_id': effect.memberId,
        'template_id': crossing.template.id,
        'template_name': crossing.template.name,
        'is_penalty': crossing.template.isPenalty,
        'direction': crossing.direction,
        'score': crossing.score,
        'threshold': crossing.template.unlockThreshold,
        'triggering_event_id': effect.triggeringEventId,
      });
      ops.add(
        sync.opFactory.auditLogAppend(
          opId: crossingAuditOpId(logId),
          houseId: effect.houseId,
          logId: logId,
          taskId: crossingTaskId(crossing.template.id),
          actorMemberId: effect.memberId,
          action: 'privilege_tier_crossing',
          justificationNotes: justification,
        ),
      );
    }

    final settings = await (_db.select(
      _db.localUserSettings,
    )).getSingleOrNull();
    await sync.emitLocalOps(
      houseId: effect.houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: null,
      ops: ops,
    );
  }

  Future<Map<String, PrivilegeTemplate>> _loadTemplates(String houseId) async {
    final row = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    if (row == null ||
        row.privilegeTemplates.isEmpty ||
        row.privilegeTemplates == '{}') {
      return PrivilegeTemplate.defaultsMap();
    }
    final decoded = jsonDecode(row.privilegeTemplates) as Map<String, dynamic>;
    final templates = <String, PrivilegeTemplate>{};
    for (final entry in decoded.entries) {
      templates[entry.key] = PrivilegeTemplate.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
    }
    final defaults = PrivilegeTemplate.defaultsMap();
    for (final entry in defaults.entries) {
      templates.putIfAbsent(entry.key, () => entry.value);
    }
    return templates;
  }
}
