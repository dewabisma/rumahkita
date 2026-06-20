import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/home/home_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

final currentGuardianProvider =
    Provider.family<AsyncValue<Housemate?>, String>((ref, houseId) {
  final cycleAsync = ref.watch(activeCycleProvider(houseId));
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

final guardianPendingReviewProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, houseId) {
  return ref
      .watch(activeCycleTasksProvider(houseId))
      .whenData(
        (tasks) => tasks
            .where((t) => t.status == TaskStatus.pendingReview)
            .toList(),
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
