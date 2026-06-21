import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/entities/cycle.dart';
import 'package:rumah/domain/entities/house_privilege.dart';
import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/privilege_status.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

export 'package:rumah/presentation/house/house_phase_providers.dart'
    show CeremonyRedirectPhase, ceremonyRouterPhaseProvider;

final draftingCycleProvider = StreamProvider.family<Cycle?, String>(
  (ref, houseId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.cyclesSync)
      ..where(
        (t) =>
            t.houseId.equals(houseId) &
            t.status.equals(CycleStatus.drafting.wireValue),
      );
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      final sorted = [...rows]..sort((a, b) => a.cycleId.compareTo(b.cycleId));
      return DriftCeremonyRepository.cycleFromRow(sorted.first);
    });
  },
);

final activeCycleProvider = StreamProvider.family<Cycle?, String>(
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

final tasksForCycleProvider = StreamProvider.family<List<Task>, String>(
  (ref, cycleId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.tasksSync)
      ..where((t) => t.cycleId.equals(cycleId));
    return query.watch().map((rows) {
      return rows
          .where((r) => r.status != TaskStatus.archived.wireValue)
          .map(DriftCeremonyRepository.taskFromRow)
          .toList();
    });
  },
);

// Re-exported for ceremony drafting; active-cycle tasks live in home_providers.

class CeremonySignoffStatus {
  const CeremonySignoffStatus({
    required this.acceptedByMemberId,
    required this.quorumMet,
    required this.localAccepted,
    required this.rulesVersionStale,
  });

  final Map<String, bool> acceptedByMemberId;
  final bool quorumMet;
  final bool localAccepted;
  final bool rulesVersionStale;
}

final ceremonySignoffStatusProvider =
    Provider.family<AsyncValue<CeremonySignoffStatus>, String>(
  (ref, cycleId) {
    final cycleAsync = ref.watch(_cycleByIdProvider(cycleId));
    final houseId = cycleAsync.asData?.value?.houseId;
    if (houseId == null) {
      return const AsyncValue.loading();
    }
    final houseAsync = ref.watch(houseProvider(houseId));
    final matesAsync = ref.watch(housematesProvider(houseId));
    final localMemberAsync = ref.watch(localMemberProvider);

    return cycleAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (cycle) {
        if (cycle == null) {
          return const AsyncValue.loading();
        }
        return houseAsync.when(
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
          data: (house) {
            return matesAsync.when(
              loading: () => const AsyncValue.loading(),
              error: (e, st) => AsyncValue.error(e, st),
              data: (mates) {
                final activeMates = mates
                    .where((m) => m.memberStatus == MemberStatus.active)
                    .toList();
                final accepted = <String, bool>{};
                var quorumMet = activeMates.isNotEmpty;
                for (final mate in activeMates) {
                  final signoff = cycle.ceremonySignoffs[mate.memberId];
                  final acceptedFlag = signoff?.accepted ?? false;
                  accepted[mate.memberId] = acceptedFlag;
                  if (!acceptedFlag) {
                    quorumMet = false;
                  }
                }
                final localId = localMemberAsync.asData?.value?.memberId;
                final rulesVersionStale = house != null &&
                    cycle.rulesVersionAtSignoff != house.rulesVersion;
                return AsyncValue.data(
                  CeremonySignoffStatus(
                    acceptedByMemberId: accepted,
                    quorumMet: quorumMet && !rulesVersionStale,
                    localAccepted: localId != null &&
                        (cycle.ceremonySignoffs[localId]?.accepted ?? false),
                    rulesVersionStale: rulesVersionStale,
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

final _cycleByIdProvider = StreamProvider.family<Cycle?, String>(
  (ref, cycleId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.cyclesSync)
      ..where((t) => t.cycleId.equals(cycleId));
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return DriftCeremonyRepository.cycleFromRow(rows.first);
    });
  },
);

final privilegesForCycleProvider =
    StreamProvider.family<List<HousePrivilege>, String>(
  (ref, cycleId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.privilegesSync)
      ..where((t) => t.cycleId.equals(cycleId));
    return query.watch().map((rows) {
      return rows
          .where((r) => r.status != PrivilegeStatus.archived.wireValue)
          .map(DriftCeremonyRepository.privilegeFromRow)
          .toList();
    });
  },
);

final houseRulesVersionProvider = StreamProvider.family<int, String>(
  (ref, houseId) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.houseSync)
      ..where((t) => t.houseId.equals(houseId));
    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return 0;
      }
      return rows.first.rulesVersion;
    });
  },
);
