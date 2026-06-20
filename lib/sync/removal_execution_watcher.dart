import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_admin_api.dart';
import 'package:rumah/sync/removal_op_ids.dart';
import 'package:uuid/uuid.dart';

/// Executes ready removal proposals via Tailscale admin API.
class RemovalExecutionWatcher {
  RemovalExecutionWatcher({
    required Ref ref,
    this.pollInterval = const Duration(seconds: 30),
  }) : _ref = ref;

  final Ref _ref;
  final Duration pollInterval;
  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => _poll());
    unawaited(_poll());
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    final houseId = _ref.read(activeHouseIdProvider).value;
    if (houseId == null || houseId.isEmpty) {
      return;
    }
    await runRemovalExecutionPoll(
      houseId: houseId,
      db: _ref.read(databaseProvider),
      sync: _ref.read(syncWriteCoordinatorProvider),
      tailscaleAdmin: await createTailscaleAdminApi(
        _ref.read(localSettingsRepositoryProvider),
      ),
      localSettings: _ref.read(localSettingsRepositoryProvider),
    );
  }
}

@visibleForTesting
Future<void> runRemovalExecutionPoll({
  required String houseId,
  required AppDatabase db,
  required SyncWriteCoordinator sync,
  required TailscaleAdminApi tailscaleAdmin,
  required LocalSettingsRepository localSettings,
  Uuid? uuid,
}) async {
  const defaultUuid = Uuid();
  final idGen = uuid ?? defaultUuid;

  final ready = await (db.select(db.removalProposalsSync)
        ..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.status.equals(ProposalStatus.readyToExecute.wireValue),
        ))
      .get();

  final settings = await (db.select(db.localUserSettings)).getSingleOrNull();
  final nodeKey = settings?.tailscaleNodeId ?? 'local-node';
  final localNodeKey = await localSettings.getTailscaleNodeKey();

  final isCreatorWithAdminKey = await _isCreatorWithAdminKey(
    db: db,
    houseId: houseId,
    localNodeKey: localNodeKey,
    localSettings: localSettings,
  );

  for (final proposal in ready) {
    final executedOpId = removalExecutedOpId(proposal.proposalId);
    final applied = await (db.select(db.syncAppliedOps)
          ..where((t) => t.opId.equals(executedOpId)))
        .getSingleOrNull();
    if (applied != null) {
      continue;
    }

    final target = await (db.select(db.housematesSync)
          ..where((t) => t.memberId.equals(proposal.targetMemberId)))
        .getSingleOrNull();
    if (target == null) {
      continue;
    }

    if (!isCreatorWithAdminKey) {
      final pendingOpId = removalPendingCreatorOpId(proposal.proposalId);
      final pendingApplied = await (db.select(db.syncAppliedOps)
            ..where((t) => t.opId.equals(pendingOpId)))
          .getSingleOrNull();
      if (pendingApplied == null) {
        final logId = idGen.v4();
        await sync.emitLocalOps(
          houseId: houseId,
          tailscaleNodeKey: nodeKey,
          senderMemberId: null,
          ops: [
            sync.opFactory.auditLogAppend(
              opId: pendingOpId,
              houseId: houseId,
              logId: logId,
              taskId: proposal.proposalId,
              actorMemberId: proposal.targetMemberId,
              action: 'removal_execution_pending_creator',
              justificationNotes: jsonEncode({
                'proposal_id': proposal.proposalId,
                'target_member_id': proposal.targetMemberId,
              }),
            ),
          ],
        );
      }
      continue;
    }

    try {
      await tailscaleAdmin.invalidateNodeKey(
        tailscaleNodeKey: target.tailscaleNodeKey,
        houseId: houseId,
      );

      final activeMembers = await _loadActiveMembers(
        db: db,
        houseId: houseId,
        excludeMemberId: proposal.targetMemberId,
      );
      await tailscaleAdmin.reconcileHouseAcl(
        houseId: houseId,
        activeMembers: activeMembers,
      );
    } on Object catch (e) {
      final logId = idGen.v4();
      await sync.emitLocalOps(
        houseId: houseId,
        tailscaleNodeKey: nodeKey,
        senderMemberId: null,
        ops: [
          sync.opFactory.auditLogAppend(
            opId: removalAuditOpId(logId),
            houseId: houseId,
            logId: logId,
            taskId: proposal.proposalId,
            actorMemberId: proposal.targetMemberId,
            action: 'removal_execution_failed',
            justificationNotes: jsonEncode({'error': e.toString()}),
          ),
        ],
      );
      continue;
    }

    await (db.delete(db.syncPeerAllowlist)..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.tailscaleNodeKey.equals(target.tailscaleNodeKey),
        ))
        .go();

    final auditLogId = idGen.v4();
    await sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: nodeKey,
      senderMemberId: null,
      ops: [
        sync.opFactory.auditLogAppend(
          opId: removalAuditOpId(auditLogId),
          houseId: houseId,
          logId: auditLogId,
          taskId: proposal.proposalId,
          actorMemberId: proposal.targetMemberId,
          action: 'removal_executed',
          justificationNotes: jsonEncode({
            'proposal_id': proposal.proposalId,
            'target_member_id': proposal.targetMemberId,
            'type': proposal.type,
          }),
        ),
        sync.opFactory.proposalStatusTransition(
          opId: executedOpId,
          houseId: houseId,
          proposalId: proposal.proposalId,
          from: ProposalStatus.readyToExecute,
          to: ProposalStatus.executed,
        ),
        sync.opFactory.memberStatusTransition(
          opId: removalEvictMemberOpId(proposal.proposalId),
          houseId: houseId,
          memberId: proposal.targetMemberId,
          from: MemberStatus.active,
          to: MemberStatus.evicted,
        ),
      ],
    );

    if (target.tailscaleNodeKey == localNodeKey) {
      await localSettings.setActiveHouseId(null);
    }
  }
}

Future<bool> _isCreatorWithAdminKey({
  required AppDatabase db,
  required String houseId,
  required String localNodeKey,
  required LocalSettingsRepository localSettings,
}) async {
  final adminKey = await localSettings.getTailscaleAdminApiKey();
  if (adminKey == null || adminKey.isEmpty) {
    return false;
  }
  final house = await (db.select(db.houseSync)
        ..where((t) => t.houseId.equals(houseId)))
      .getSingleOrNull();
  if (house == null) {
    return false;
  }
  final creator = await (db.select(db.housematesSync)
        ..where((t) => t.memberId.equals(house.creatorMemberId)))
      .getSingleOrNull();
  return creator?.tailscaleNodeKey == localNodeKey;
}

Future<List<HouseAclMember>> _loadActiveMembers({
  required AppDatabase db,
  required String houseId,
  String? excludeMemberId,
}) async {
  final rows = await (db.select(db.housematesSync)
        ..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.memberStatus.equals(MemberStatus.active.wireValue),
        ))
      .get();
  return rows
      .where((r) => r.memberId != excludeMemberId)
      .map(
        (r) => HouseAclMember(
          memberId: r.memberId,
          tailscaleNodeKey: r.tailscaleNodeKey,
        ),
      )
      .toList();
}

final removalExecutionWatcherProvider = Provider<RemovalExecutionWatcher>((ref) {
  final watcher = RemovalExecutionWatcher(ref: ref);
  ref.onDispose(watcher.dispose);
  ref.keepAlive();
  watcher.start();
  return watcher;
});

final tailscaleAdminApiProvider = Provider<TailscaleAdminApi>(
  (ref) => ref.watch(appStateProvider).tailscaleAdminApi,
);
