import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/entities/house_privilege.dart';
import 'package:rumah/domain/entities/privilege_redemption.dart';
import 'package:rumah/domain/entities/privilege_state.dart';
import 'package:rumah/domain/enums/redemption_status.dart';
import 'package:rumah/presentation/ceremony/ceremony_providers.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

/// Points balance for a member (spendable wallet).
final memberPointsBalanceProvider = Provider.family<
    AsyncValue<int>,
    ({String houseId, String memberId})>((ref, args) {
  final matesAsync = ref.watch(housematesProvider(args.houseId));
  return matesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (mates) {
      final mate = mates
          .where((m) => m.memberId == args.memberId)
          .firstOrNull;
      return AsyncValue.data(mate?.lifetimeScore ?? 0);
    },
  );
});

/// Local member points balance on the active house.
final localMemberPointsBalanceProvider =
    Provider.family<AsyncValue<int>, String>((ref, houseId) {
  final localMemberAsync = ref.watch(localMemberProvider);
  return localMemberAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (member) {
      if (member == null) {
        return const AsyncValue.data(0);
      }
      return ref.watch(
        memberPointsBalanceProvider(
          (houseId: houseId, memberId: member.memberId),
        ),
      );
    },
  );
});

/// Active-cycle privilege catalog.
final activeCyclePrivilegesProvider =
    Provider.family<AsyncValue<List<HousePrivilege>>, String>((ref, houseId) {
  final cycleAsync = ref.watch(activeCycleProvider(houseId));
  return cycleAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (cycle) {
      if (cycle == null) {
        return const AsyncValue.data([]);
      }
      return ref.watch(privilegesForCycleProvider(cycle.cycleId));
    },
  );
});

final memberRedemptionsProvider = StreamProvider.family<
    List<PrivilegeRedemption>,
    ({String houseId, String memberId})>((ref, args) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.privilegeRedemptionEvents)
    ..where(
      (t) =>
          t.houseId.equals(args.houseId) &
          t.memberId.equals(args.memberId) &
          t.status.equals(RedemptionStatus.active.wireValue),
    );
  return query.watch().map(
        (rows) => rows
            .map(DriftCeremonyRepository.redemptionFromRow)
            .toList(growable: false),
      );
});

/// Owned active entitlements for a member on the active cycle.
final memberPrivilegeStatesProvider = Provider.family<
    AsyncValue<List<PrivilegeState>>,
    ({String houseId, String memberId})>((ref, args) {
  final catalogAsync = ref.watch(activeCyclePrivilegesProvider(args.houseId));
  final redemptionsAsync = ref.watch(
    memberRedemptionsProvider(
      (houseId: args.houseId, memberId: args.memberId),
    ),
  );

  if (catalogAsync.isLoading || redemptionsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (catalogAsync.hasError) {
    return AsyncValue.error(catalogAsync.error!, catalogAsync.stackTrace!);
  }
  if (redemptionsAsync.hasError) {
    return AsyncValue.error(redemptionsAsync.error!, redemptionsAsync.stackTrace!);
  }

  final catalog = catalogAsync.value ?? [];
  final redemptions = redemptionsAsync.value ?? [];
  final catalogById = {for (final p in catalog) p.privilegeId: p};

  final states = <PrivilegeState>[];
  for (final redemption in redemptions) {
    final privilege = catalogById[redemption.privilegeId];
    if (privilege != null) {
      states.add(PrivilegeState(privilege: privilege, redemption: redemption));
    }
  }
  states.sort((a, b) => a.name.compareTo(b.name));
  return AsyncValue.data(states);
});

/// Privilege wallet view for the local member on the active house.
final localMemberPrivilegeWalletProvider =
    Provider.family<AsyncValue<PrivilegeWallet>, String>((ref, houseId) {
  final localMemberAsync = ref.watch(localMemberProvider);
  final balanceAsync = ref.watch(localMemberPointsBalanceProvider(houseId));
  final catalogAsync = ref.watch(activeCyclePrivilegesProvider(houseId));

  return localMemberAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (member) {
      if (member == null) {
        return AsyncValue.data(
          PrivilegeWallet(balance: 0, catalog: const [], entitlements: const []),
        );
      }
      final entitlementsAsync = ref.watch(
        memberPrivilegeStatesProvider(
          (houseId: houseId, memberId: member.memberId),
        ),
      );
      if (balanceAsync.isLoading ||
          catalogAsync.isLoading ||
          entitlementsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (balanceAsync.hasError) {
        return AsyncValue.error(balanceAsync.error!, balanceAsync.stackTrace!);
      }
      if (catalogAsync.hasError) {
        return AsyncValue.error(catalogAsync.error!, catalogAsync.stackTrace!);
      }
      if (entitlementsAsync.hasError) {
        return AsyncValue.error(
          entitlementsAsync.error!,
          entitlementsAsync.stackTrace!,
        );
      }
      return AsyncValue.data(
        PrivilegeWallet(
          balance: balanceAsync.value ?? 0,
          catalog: catalogAsync.value ?? [],
          entitlements: entitlementsAsync.value ?? [],
        ),
      );
    },
  );
});

class PrivilegeWallet {
  const PrivilegeWallet({
    required this.balance,
    required this.catalog,
    required this.entitlements,
  });

  final int balance;
  final List<HousePrivilege> catalog;
  final List<PrivilegeState> entitlements;
}

List<PrivilegeState> activeEntitlements(List<PrivilegeState> states) {
  return states.where((s) => s.isActive).toList();
}
