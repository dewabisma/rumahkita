import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:uuid/uuid.dart';

/// Appends audit log entries when a cycle enters handover.
class HandoverMergeSideEffectHandler implements MergeSideEffectHandler {
  HandoverMergeSideEffectHandler(this._db);

  final AppDatabase _db;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      if (effect is! HandoverStarted) {
        continue;
      }
      const uuid = Uuid();
      await _db
          .into(_db.auditLogAppendOnly)
          .insert(
            AuditLogAppendOnlyCompanion.insert(
              logId: uuid.v4(),
              houseId: effect.houseId,
              taskId: effect.cycleId,
              actorMemberId: effect.guardianMemberId,
              action: 'cycle_handover_started',
              hlc: Uint8List.fromList(effect.hlc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }
}
