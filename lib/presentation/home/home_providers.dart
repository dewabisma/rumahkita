import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

final activeCycleTasksProvider = StreamProvider.family<List<Task>, String>((
  ref,
  houseId,
) {
  final db = ref.watch(databaseProvider);
  final cyclesQuery = db.select(db.cyclesSync)
    ..where(
      (t) =>
          t.houseId.equals(houseId) &
          t.status.equals(CycleStatus.active.wireValue),
    );
  return cyclesQuery.watch().asyncMap((cycles) async {
    if (cycles.isEmpty) {
      return <Task>[];
    }
    final cycleId = cycles.first.cycleId;
    final tasks = await (db.select(
      db.tasksSync,
    )..where((t) => t.cycleId.equals(cycleId))).get();
    return tasks
        .where((r) => r.status != TaskStatus.archived.wireValue)
        .map(DriftCeremonyRepository.taskFromRow)
        .toList();
  });
});

final openTasksProvider = Provider.family<AsyncValue<List<Task>>, String>((
  ref,
  houseId,
) {
  return ref
      .watch(activeCycleTasksProvider(houseId))
      .whenData(
        (tasks) => tasks.where((t) => t.status == TaskStatus.open).toList(),
      );
});

final pendingReviewTasksProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, houseId) {
      return ref
          .watch(activeCycleTasksProvider(houseId))
          .whenData(
            (tasks) => tasks
                .where((t) => t.status == TaskStatus.pendingReview)
                .toList(),
          );
    });

final isLocalGuardianProvider = Provider.family<AsyncValue<bool>, String>((
  ref,
  houseId,
) {
  final cycleAsync = ref.watch(activeCycleProvider(houseId));
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

final localClaimedTasksProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, houseId) {
      final tasksAsync = ref.watch(activeCycleTasksProvider(houseId));
      final localMemberAsync = ref.watch(localMemberProvider);
      return tasksAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (tasks) {
          return localMemberAsync.when(
            loading: () => const AsyncValue.loading(),
            error: (e, st) => AsyncValue.error(e, st),
            data: (member) {
              if (member == null) {
                return const AsyncValue.data([]);
              }
              return AsyncValue.data(
                tasks
                    .where(
                      (t) => t.claimedByMemberIds.contains(member.memberId),
                    )
                    .toList(),
              );
            },
          );
        },
      );
    });

final localPendingReviewTasksProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, houseId) {
      return ref
          .watch(localClaimedTasksProvider(houseId))
          .whenData(
            (tasks) => tasks
                .where((t) => t.status == TaskStatus.pendingReview)
                .toList(),
          );
    });
