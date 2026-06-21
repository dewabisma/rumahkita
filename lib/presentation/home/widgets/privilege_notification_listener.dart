import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart'
    show housematesProvider, localMemberProvider;
import 'package:rumah/theme/app_colors.dart';

final privilegeRedeemAuditProvider =
    StreamProvider.family<List<AuditLogEntry>, String>((ref, houseId) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.auditLogAppendOnly)
    ..where(
      (t) =>
          t.houseId.equals(houseId) &
          t.action.equals('privilege_redeemed'),
    );
  return query.watch().map(
    (rows) => rows
        .map(
          (row) => AuditLogEntry(
            logId: row.logId,
            houseId: row.houseId,
            taskId: row.taskId,
            actorMemberId: row.actorMemberId,
            action: row.action,
            justificationNotes: row.justificationNotes,
            hlc: row.hlc,
          ),
        )
        .toList(),
  );
});

String redeemSnackBarMessage({
  required Map<String, dynamic> payload,
  required String? localMemberId,
  required String? localNickname,
  required Map<String, String> nicknameByMemberId,
}) {
  final privilegeName = payload['privilege_name'] as String? ?? 'A perk';
  final pointCost = payload['point_cost'] as int? ?? 0;
  final memberId = payload['member_id'] as String?;
  final isLocal = memberId != null && memberId == localMemberId;
  final who = isLocal ? 'You' : (nicknameByMemberId[memberId] ?? 'A housemate');

  return isLocal
      ? 'You redeemed $privilegeName for $pointCost points.'
      : '$who redeemed $privilegeName.';
}

/// Shows gentle snackbars when privilege redemptions are recorded.
class PrivilegeNotificationListener extends ConsumerStatefulWidget {
  const PrivilegeNotificationListener({
    super.key,
    required this.houseId,
    required this.child,
  });

  final String houseId;
  final Widget child;

  @override
  ConsumerState<PrivilegeNotificationListener> createState() =>
      _PrivilegeNotificationListenerState();
}

class _PrivilegeNotificationListenerState
    extends ConsumerState<PrivilegeNotificationListener> {
  final _seenLogIds = <String>{};
  var _initialized = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    ref.listen(privilegeRedeemAuditProvider(widget.houseId), (prev, next) {
      final entries = next.asData?.value;
      if (entries == null) {
        return;
      }
      if (!_initialized) {
        _seenLogIds.addAll(entries.map((e) => e.logId));
        _initialized = true;
        return;
      }
      final localMember = ref.read(localMemberProvider).asData?.value;
      final mates = ref.read(housematesProvider(widget.houseId)).asData?.value;
      final nicknames = {
        if (mates != null)
          for (final m in mates) m.memberId: m.nickname,
      };
      for (final entry in entries) {
        if (_seenLogIds.contains(entry.logId)) {
          continue;
        }
        _seenLogIds.add(entry.logId);
        final notes = entry.justificationNotes;
        if (notes == null || notes.isEmpty) {
          continue;
        }
        final payload = jsonDecode(notes) as Map<String, dynamic>;
        final message = redeemSnackBarMessage(
          payload: payload,
          localMemberId: localMember?.memberId,
          localNickname: localMember?.nickname,
          nicknameByMemberId: nicknames,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: colors.surfaceElevated,
          ),
        );
      }
    });

    return widget.child;
  }
}
