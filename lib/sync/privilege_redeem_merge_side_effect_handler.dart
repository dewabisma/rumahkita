import 'dart:convert';

import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/privilege_redeem_ids.dart';
import 'package:rumah/sync/sync_operation.dart';

/// Emits redeem confirmation audits when a privilege redemption is applied.
class PrivilegeRedeemMergeSideEffectHandler implements MergeSideEffectHandler {
  PrivilegeRedeemMergeSideEffectHandler(this._db);

  final AppDatabase _db;
  SyncWriteCoordinator? _sync;

  void bindSync(SyncWriteCoordinator sync) => _sync = sync;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      if (effect is PrivilegeRedeemed) {
        await _handleRedeemed(effect);
      }
    }
  }

  Future<void> _handleRedeemed(PrivilegeRedeemed effect) async {
    final sync = _sync;
    if (sync == null) {
      return;
    }

    final logId = privilegeRedeemAuditLogId(effect.redemptionId);
    final justification = jsonEncode({
      'member_id': effect.memberId,
      'privilege_id': effect.privilegeId,
      'privilege_name': effect.privilegeName,
      'point_cost': effect.pointCost,
      'redemption_id': effect.redemptionId,
    });

    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    await sync.emitLocalOps(
      houseId: effect.houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: effect.memberId,
      ops: [
        sync.opFactory.auditLogAppend(
          opId: privilegeRedeemAuditOpId(logId),
          houseId: effect.houseId,
          logId: logId,
          taskId: 'privilege:${effect.privilegeId}',
          actorMemberId: effect.memberId,
          action: 'privilege_redeemed',
          justificationNotes: justification,
        ),
      ],
    );
  }
}
