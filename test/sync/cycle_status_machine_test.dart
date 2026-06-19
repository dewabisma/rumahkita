import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('drafting to active to completed only', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: uuid.v4(),
            status: 'drafting',
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    await harness.apply(
      harness.cycleStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        cycleId: cycleId,
        from: 'drafting',
        to: 'active',
      ),
      houseId,
    );
    await harness.apply(
      harness.cycleStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        cycleId: cycleId,
        from: 'active',
        to: 'completed',
      ),
      houseId,
    );

    final cycle = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingle();
    expect(cycle.status, 'completed');
  });

  test('backward transition rejected', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: uuid.v4(),
            status: 'active',
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final result = await harness.apply(
      harness.cycleStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        cycleId: cycleId,
        from: 'active',
        to: 'drafting',
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });
}
