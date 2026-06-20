import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/removal_op_ids.dart';

/// Polls proposals past [voting_window_ends_at_hlc] and rejects them.
class RemovalProposalExpiryWatcher {
  RemovalProposalExpiryWatcher({
    required Ref ref,
    this.pollInterval = const Duration(seconds: 30),
  }) : _ref = ref;

  final Ref _ref;
  final Duration pollInterval;
  Timer? _timer;
  HlcService? _hlcService;

  void start() {
    _hlcService = _ref.read(appStateProvider).hlcService;
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
    await runRemovalProposalExpiryPoll(
      houseId: houseId,
      db: _ref.read(databaseProvider),
      sync: _ref.read(syncWriteCoordinatorProvider),
      hlcService: _hlcService ?? _ref.read(appStateProvider).hlcService,
    );
  }
}

@visibleForTesting
Future<void> runRemovalProposalExpiryPoll({
  required String houseId,
  required AppDatabase db,
  required SyncWriteCoordinator sync,
  required HlcService hlcService,
}) async {
  final nowHlc = hlcService.now();

  final proposed = await (db.select(db.removalProposalsSync)
        ..where(
          (t) =>
              t.houseId.equals(houseId) &
              t.status.equals(ProposalStatus.proposed.wireValue),
        ))
      .get();

  final settings = await (db.select(db.localUserSettings)).getSingleOrNull();
  final nodeKey = settings?.tailscaleNodeId ?? 'local-node';

  for (final proposal in proposed) {
    final endsBytes = proposal.votingWindowEndsAtHlc;
    if (endsBytes == null || endsBytes.isEmpty) {
      continue;
    }
    if (!HandoverCycleHelpers.hasEnded(
      endsAtHlcBytes: endsBytes,
      nowHlc: nowHlc,
    )) {
      continue;
    }
    final opId = removalRejectedOpId(proposal.proposalId);
    final applied = await (db.select(db.syncAppliedOps)
          ..where((t) => t.opId.equals(opId)))
        .getSingleOrNull();
    if (applied != null) {
      continue;
    }
    await sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: nodeKey,
      senderMemberId: null,
      ops: [
        sync.opFactory.proposalStatusTransition(
          opId: opId,
          houseId: houseId,
          proposalId: proposal.proposalId,
          from: ProposalStatus.proposed,
          to: ProposalStatus.rejected,
        ),
      ],
    );
  }
}

final removalProposalExpiryWatcherProvider =
    Provider<RemovalProposalExpiryWatcher>((ref) {
  final watcher = RemovalProposalExpiryWatcher(ref: ref);
  ref.onDispose(watcher.dispose);
  ref.keepAlive();
  watcher.start();
  return watcher;
});
