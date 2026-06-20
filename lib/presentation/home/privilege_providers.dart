import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/domain/entities/privilege_state.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/sync/privilege_tier_evaluator.dart';

/// Privilege states for a specific member, computed from live score + templates.
final memberPrivilegeStatesProvider = Provider.family<
    AsyncValue<List<PrivilegeState>>,
    ({String houseId, String memberId})>((ref, args) {
  final templatesAsync = ref.watch(privilegeTemplatesProvider(args.houseId));
  final matesAsync = ref.watch(housematesProvider(args.houseId));

  return templatesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (templates) {
      return matesAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (mates) {
          final mate = mates
              .where((m) => m.memberId == args.memberId)
              .firstOrNull;
          if (mate == null) {
            return const AsyncValue.data([]);
          }
          return AsyncValue.data(
            evaluateAll(templates: templates, score: mate.lifetimeScore),
          );
        },
      );
    },
  );
});

/// Privilege states for the local member on the active house.
final localMemberPrivilegeStatesProvider =
    Provider.family<AsyncValue<List<PrivilegeState>>, String>((ref, houseId) {
  final localMemberAsync = ref.watch(localMemberProvider);
  return localMemberAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (member) {
      if (member == null) {
        return const AsyncValue.data([]);
      }
      return ref.watch(
        memberPrivilegeStatesProvider(
          (houseId: houseId, memberId: member.memberId),
        ),
      );
    },
  );
});

/// Active perks only (rewards unlocked or penalties applied).
List<PrivilegeState> activePerks(List<PrivilegeState> states) {
  return states.where((s) => s.isActive).toList();
}

/// Inactive rewards and cleared penalties for summary display.
List<PrivilegeState> inactivePerks(List<PrivilegeState> states) {
  return states.where((s) => !s.isActive && !s.isPenalty).toList();
}
