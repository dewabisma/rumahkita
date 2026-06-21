import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/enums/privilege_status.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

/// Copies non-archived privileges from the prior cycle when drafting starts.
class PrivilegeCycleMergeSideEffectHandler implements MergeSideEffectHandler {
  PrivilegeCycleMergeSideEffectHandler(this._db);

  final AppDatabase _db;
  SyncWriteCoordinator? _sync;
  final Uuid _uuid = const Uuid();

  void bindSync(SyncWriteCoordinator sync) => _sync = sync;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      if (effect is DraftingCycleCreated) {
        await _copyPrivilegesFromPriorCycle(effect);
      }
    }
  }

  Future<void> _copyPrivilegesFromPriorCycle(DraftingCycleCreated effect) async {
    final sync = _sync;
    if (sync == null) {
      return;
    }

    final cycles = await (_db.select(_db.cyclesSync)
          ..where((t) => t.houseId.equals(effect.houseId)))
        .get();
    if (cycles.length <= 1) {
      return;
    }

    cycles.sort((a, b) {
      final hlcA = HlcService.fromBytes(Uint8List.fromList(a.updatedAtHlc));
      final hlcB = HlcService.fromBytes(Uint8List.fromList(b.updatedAtHlc));
      return hlcA.compareTo(hlcB);
    });

    final priorCandidates = cycles
        .where((c) => c.cycleId != effect.cycleId)
        .toList();
    if (priorCandidates.isEmpty) {
      return;
    }
    final priorCycle = priorCandidates.last;

    final priorPrivileges = await (_db.select(_db.privilegesSync)
          ..where(
            (t) =>
                t.cycleId.equals(priorCycle.cycleId) &
                t.status.equals(PrivilegeStatus.active.wireValue),
          ))
        .get();
    if (priorPrivileges.isEmpty) {
      return;
    }

    final ops = <SyncOperation>[];
    for (final privilege in priorPrivileges) {
      final newPrivilegeId = _uuid.v5(
        Uuid.NAMESPACE_URL,
        '${effect.cycleId}|${privilege.privilegeId}',
      );
      ops.add(
        sync.opFactory.privilegeCreate(
          opId: _uuid.v4(),
          houseId: effect.houseId,
          privilegeId: newPrivilegeId,
          cycleId: effect.cycleId,
          name: privilege.name,
          description: privilege.description,
          pointCost: privilege.pointCost,
          usageMode: privilege.usageMode,
        ),
      );
    }

    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    await sync.emitLocalOps(
      houseId: effect.houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: null,
      ops: ops,
    );
  }
}
