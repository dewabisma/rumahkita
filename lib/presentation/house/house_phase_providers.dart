import 'package:drift/drift.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/entities/cycle.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/sync/cycle_retrospective_calculator.dart';

export 'package:rumah/sync/cycle_retrospective_calculator.dart'
    show CycleRetrospective, CycleRetrospectiveMemberStats;

enum HouseRedirectPhase {
  none,
  handoverCloseout,
  handoverRetro,
  handoverCeremonyPending,
  drafting,
  active,
}

class HousePhaseContext {
  const HousePhaseContext({
    required this.phase,
    this.handoverCycle,
    this.draftingCycle,
    this.activeCycle,
  });

  final HouseRedirectPhase phase;
  final Cycle? handoverCycle;
  final Cycle? draftingCycle;
  final Cycle? activeCycle;
}

enum CeremonyRedirectPhase { none, drafting, active }

final houseRouterPhaseProvider = Provider<AsyncValue<HousePhaseContext>>((ref) {
  final houseId = ref.watch(activeHouseIdProvider).value;
  if (houseId == null || houseId.isEmpty) {
    return const AsyncValue.data(
      HousePhaseContext(phase: HouseRedirectPhase.none),
    );
  }
  return ref.watch(_housePhaseForHouseProvider(houseId));
});

/// Backward-compatible redirect phase for router during migration.
final ceremonyRouterPhaseProvider = Provider<AsyncValue<CeremonyRedirectPhase>>(
  (ref) {
    final phaseAsync = ref.watch(houseRouterPhaseProvider);
    return phaseAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (ctx) {
        switch (ctx.phase) {
          case HouseRedirectPhase.drafting:
            return const AsyncValue.data(CeremonyRedirectPhase.drafting);
          case HouseRedirectPhase.active:
            return const AsyncValue.data(CeremonyRedirectPhase.active);
          default:
            return const AsyncValue.data(CeremonyRedirectPhase.none);
        }
      },
    );
  },
);

final _housePhaseForHouseProvider =
    StreamProvider.family<HousePhaseContext, String>((ref, houseId) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.cyclesSync)
    ..where((t) => t.houseId.equals(houseId));
  return query.watch().map((rows) {
    Cycle? handover;
    Cycle? drafting;
    Cycle? active;
    for (final row in rows) {
      final cycle = DriftCeremonyRepository.cycleFromRow(row);
      switch (cycle.status) {
        case CycleStatus.handover:
          handover = cycle;
        case CycleStatus.drafting:
          drafting = cycle;
        case CycleStatus.active:
          active = cycle;
        case CycleStatus.completed:
          break;
      }
    }

    if (handover != null) {
      final step = handover.handoverStep ?? HandoverStep.closeout;
      final phase = switch (step) {
        HandoverStep.closeout => HouseRedirectPhase.handoverCloseout,
        HandoverStep.retro => HouseRedirectPhase.handoverRetro,
        HandoverStep.ceremonyPending =>
          HouseRedirectPhase.handoverCeremonyPending,
      };
      return HousePhaseContext(
        phase: phase,
        handoverCycle: handover,
        draftingCycle: drafting,
        activeCycle: active,
      );
    }
    if (drafting != null) {
      return HousePhaseContext(
        phase: HouseRedirectPhase.drafting,
        draftingCycle: drafting,
      );
    }
    if (active != null) {
      return HousePhaseContext(
        phase: HouseRedirectPhase.active,
        activeCycle: active,
      );
    }
    return const HousePhaseContext(phase: HouseRedirectPhase.none);
  });
});

final handoverCycleProvider = StreamProvider.family<Cycle?, String>(
  (ref, houseId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.cyclesSync)
      ..where(
        (t) =>
            t.houseId.equals(houseId) &
            t.status.equals(CycleStatus.handover.wireValue),
      );
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return DriftCeremonyRepository.cycleFromRow(rows.first);
    });
  },
);

final liveCycleProvider = StreamProvider.family<Cycle?, String>(
  (ref, houseId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.cyclesSync)
      ..where((t) => t.houseId.equals(houseId));
    return query.watch().map((rows) {
      final live = rows.where(
        (r) =>
            r.status == CycleStatus.active.wireValue ||
            r.status == CycleStatus.handover.wireValue,
      );
      if (live.isEmpty) {
        return null;
      }
      return DriftCeremonyRepository.cycleFromRow(live.first);
    });
  },
);

final gameplayCycleProvider = StreamProvider.family<Cycle?, String>(
  (ref, houseId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.cyclesSync)
      ..where(
        (t) =>
            t.houseId.equals(houseId) &
            t.status.equals(CycleStatus.active.wireValue),
      );
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return DriftCeremonyRepository.cycleFromRow(rows.first);
    });
  },
);

final handoverCloseoutGateProvider = Provider.family<bool, String>((ref, houseId) {
  final handover = ref.watch(handoverCycleProvider(houseId)).value;
  if (handover == null) {
    return false;
  }
  return handover.handoverStep == HandoverStep.closeout ||
      handover.handoverStep == null;
});

final cycleEndsAtProvider = StreamProvider.family<List<int>?, String>(
  (ref, cycleId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.cyclesSync)
      ..where((t) => t.cycleId.equals(cycleId));
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return rows.first.endsAtHlc;
    });
  },
);

final cycleRetrospectiveProvider =
    Provider.family<AsyncValue<CycleRetrospectiveData>, String>(
  (ref, houseId) {
    final handoverAsync = ref.watch(handoverCycleProvider(houseId));
    final matesAsync = ref.watch(housematesProvider(houseId));
    return handoverAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (handover) {
        if (handover == null) {
          return const AsyncValue.data(CycleRetrospectiveData.empty());
        }
        return matesAsync.when(
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
          data: (mates) {
            final tasksAsync =
                ref.watch(_handoverCycleTasksProvider(handover.cycleId));
            return tasksAsync.when(
              loading: () => const AsyncValue.loading(),
              error: (e, st) => AsyncValue.error(e, st),
              data: (tasks) {
                final currentScores = {
                  for (final m in mates) m.memberId: m.lifetimeScore,
                };
                final retro = calculateCycleRetrospective(
                  cycleStartScoresJson: handover.cycleStartScoresJson,
                  currentScoresByMemberId: currentScores,
                  cycleTasks: tasks,
                );
                return AsyncValue.data(
                  CycleRetrospectiveData(
                    retrospective: retro,
                    handoverCycle: handover,
                  ),
                );
              },
            );
          },
        );
      },
    );
  },
);

class CycleRetrospectiveData {
  const CycleRetrospectiveData({
    required this.retrospective,
    required this.handoverCycle,
  });

  const CycleRetrospectiveData.empty()
      : retrospective = null,
        handoverCycle = null;

  final CycleRetrospective? retrospective;
  final Cycle? handoverCycle;
}

final _handoverCycleTasksProvider = StreamProvider.family<List<Task>, String>(
  (ref, cycleId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.tasksSync)
      ..where((t) => t.cycleId.equals(cycleId));
    return query.watch().map(
      (rows) => rows
          .where((r) => r.status != TaskStatus.archived.wireValue)
          .map(DriftCeremonyRepository.taskFromRow)
          .toList(),
    );
  },
);
