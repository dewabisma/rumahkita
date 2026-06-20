import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/presentation/home/home_providers.dart';
import 'package:rumah/presentation/house/house_phase_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

final currentGuardianProvider =
    Provider.family<AsyncValue<Housemate?>, String>((ref, houseId) {
  final cycleAsync = ref.watch(gameplayCycleProvider(houseId));
  final matesAsync = ref.watch(housematesProvider(houseId));

  return cycleAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (cycle) {
      if (cycle == null) {
        return const AsyncValue.data(null);
      }
      return matesAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (mates) {
          final guardian = mates
              .where((m) => m.memberId == cycle.activeGuardianMemberId)
              .firstOrNull;
          return AsyncValue.data(guardian);
        },
      );
    },
  );
});

final isLocalGuardianProvider = Provider.family<AsyncValue<bool>, String>((
  ref,
  houseId,
) {
  final cycleAsync = ref.watch(gameplayCycleProvider(houseId));
  final localMemberAsync = ref.watch(localMemberProvider);
  return cycleAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (cycle) {
      return localMemberAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (member) {
          if (cycle == null || member == null) {
            return const AsyncValue.data(false);
          }
          return AsyncValue.data(
            cycle.activeGuardianMemberId == member.memberId,
          );
        },
      );
    },
  );
});

final guardianPendingReviewProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, houseId) {
  final inCloseout = ref.watch(handoverCloseoutGateProvider(houseId));
  final cycleId = inCloseout
      ? ref.watch(handoverCycleProvider(houseId)).value?.cycleId
      : ref.watch(gameplayCycleProvider(houseId)).value?.cycleId;
  if (cycleId == null) {
    return const AsyncValue.data([]);
  }
  return ref.watch(_pendingReviewForCycleProvider(cycleId));
});

final _pendingReviewForCycleProvider =
    StreamProvider.family<List<Task>, String>((ref, cycleId) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.tasksSync)
    ..where((t) => t.cycleId.equals(cycleId));
  return query.watch().map(
    (rows) => rows
        .where((r) => r.status == TaskStatus.pendingReview.wireValue)
        .map(DriftCeremonyRepository.taskFromRow)
        .toList(),
  );
});

final isHandoverGuardianProvider = Provider.family<AsyncValue<bool>, String>((
  ref,
  houseId,
) {
  final handoverAsync = ref.watch(handoverCycleProvider(houseId));
  final localMemberAsync = ref.watch(localMemberProvider);
  return handoverAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (handover) {
      return localMemberAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (member) {
          if (handover == null || member == null) {
            return const AsyncValue.data(false);
          }
          return AsyncValue.data(
            handover.activeGuardianMemberId == member.memberId,
          );
        },
      );
    },
  );
});

final guardianInProgressTasksProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, houseId) {
  return ref
      .watch(activeCycleTasksProvider(houseId))
      .whenData(
        (tasks) => tasks
            .where(
              (t) =>
                  t.status == TaskStatus.open &&
                  t.claimedByMemberIds.isNotEmpty,
            )
            .toList(),
      );
});

final houseScoreboardProvider =
    Provider.family<AsyncValue<List<Housemate>>, String>((ref, houseId) {
  return ref.watch(housematesProvider(houseId)).whenData((mates) {
    final active = mates
        .where((m) => m.memberStatus == MemberStatus.active)
        .toList()
      ..sort((a, b) => b.lifetimeScore.compareTo(a.lifetimeScore));
    return active;
  });
});
