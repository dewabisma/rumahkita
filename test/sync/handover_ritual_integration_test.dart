import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('expire to handover then rollover activates drafting cycle', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final activeCycleId = uuid.v4();
    final memberA = uuid.v4();
    final started = harness.hlcService.toBytes(harness.hlcService.now());
    final pastEnds = HandoverCycleHelpers.computeEndsAtHlc(
      startedAtHlc: started,
      cycleDurationDays: 0,
    );

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: started,
            updatedAtHlc: started,
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);
    await (harness.db.update(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(memberA)))
        .write(const HousematesSyncCompanion(rotationOrderIndex: Value(0)));
    await harness.seedCycle(
      houseId: houseId,
      cycleId: activeCycleId,
      guardianMemberId: memberA,
      status: CycleStatus.active.wireValue,
    );
    await (harness.db.update(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(activeCycleId)))
        .write(
          CyclesSyncCompanion(
            startedAtHlc: Value(started),
            endsAtHlc: Value(pastEnds),
            cycleStartScoresJson: Value(jsonEncode({memberA: 0})),
          ),
        );

    final ceremonyRepo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    await ceremonyRepo.expireCycleToHandover(
      houseId: houseId,
      cycleId: activeCycleId,
    );

    var handover = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(activeCycleId)))
        .getSingle();
    expect(handover.status, CycleStatus.handover.wireValue);
    expect(handover.handoverStep, HandoverStep.closeout.wireValue);

    await ceremonyRepo.advanceHandoverStep(
      houseId: houseId,
      cycleId: activeCycleId,
      actorMemberId: memberA,
      from: HandoverStep.closeout.wireValue,
      to: HandoverStep.retro.wireValue,
    );

    await ceremonyRepo.startNextCycleCeremony(
      houseId: houseId,
      handoverCycleId: activeCycleId,
      actorMemberId: memberA,
    );

    handover = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(activeCycleId)))
        .getSingle();
    expect(handover.handoverStep, HandoverStep.ceremonyPending.wireValue);

    final drafting = await (harness.db.select(harness.db.cyclesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.status.equals(CycleStatus.drafting.wireValue),
          ))
        .getSingle();
    expect(drafting.cycleId, isNot(activeCycleId));

    await ceremonyRepo.acceptRules(
      houseId: houseId,
      cycleId: drafting.cycleId,
      memberId: memberA,
    );

    final activated = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(drafting.cycleId)))
        .getSingle();
    expect(activated.status, CycleStatus.active.wireValue);

    final completed = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(activeCycleId)))
        .getSingle();
    expect(completed.status, CycleStatus.completed.wireValue);
  });
}
