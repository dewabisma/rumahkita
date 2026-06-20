import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/sync/hlc.dart';

/// Polls active cycles and expires them when [ends_at_hlc] is reached.
class HandoverExpiryWatcher {
  HandoverExpiryWatcher({
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
    final db = _ref.read(databaseProvider);
    final hlc = _hlcService ?? _ref.read(appStateProvider).hlcService;
    final nowHlc = hlc.now();

    final activeCycles = await (db.select(db.cyclesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.status.equals(CycleStatus.active.wireValue),
          ))
        .get();

    final ceremonyRepo = _ref.read(ceremonyRepositoryProvider);
    for (final cycle in activeCycles) {
      if (HandoverCycleHelpers.hasEnded(
        endsAtHlcBytes: cycle.endsAtHlc,
        nowHlc: nowHlc,
      )) {
        await ceremonyRepo.expireCycleToHandover(
          houseId: houseId,
          cycleId: cycle.cycleId,
        );
      }
    }
  }
}

final handoverExpiryWatcherProvider = Provider<HandoverExpiryWatcher>((ref) {
  final watcher = HandoverExpiryWatcher(ref: ref);
  ref.onDispose(watcher.dispose);
  ref.keepAlive();
  watcher.start();
  return watcher;
});
