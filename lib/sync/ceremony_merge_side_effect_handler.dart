import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/sync/merge_side_effect.dart';

/// Clears ceremony signoffs when rules or task points change during drafting.
class CeremonyMergeSideEffectHandler implements MergeSideEffectHandler {
  CeremonyMergeSideEffectHandler(this._db);

  final AppDatabase _db;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      switch (effect) {
        case RulesVersionBumped():
          await _clearDraftingCycles(
            houseId: effect.houseId,
            rulesVersion: effect.newVersion,
          );
        case TaskPointsChanged():
          await _clearCycleSignoffs(cycleId: effect.cycleId);
      }
    }
  }

  Future<void> _clearDraftingCycles({
    required String houseId,
    required int rulesVersion,
  }) async {
    final cycles = await (_db.select(_db.cyclesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.status.equals(CycleStatus.drafting.wireValue),
          ))
        .get();
    for (final cycle in cycles) {
      await (_db.update(_db.cyclesSync)
            ..where((t) => t.cycleId.equals(cycle.cycleId)))
          .write(
        CyclesSyncCompanion(
          ceremonySignoffs: const Value('{}'),
          rulesVersionAtSignoff: Value(rulesVersion),
        ),
      );
    }
  }

  Future<void> _clearCycleSignoffs({required String cycleId}) async {
    final cycle = await (_db.select(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingleOrNull();
    if (cycle == null || cycle.status != CycleStatus.drafting.wireValue) {
      return;
    }
    final house = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(cycle.houseId)))
        .getSingleOrNull();
    await (_db.update(_db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(
      CyclesSyncCompanion(
        ceremonySignoffs: const Value('{}'),
        rulesVersionAtSignoff: Value(house?.rulesVersion ?? cycle.rulesVersionAtSignoff),
      ),
    );
  }
}
