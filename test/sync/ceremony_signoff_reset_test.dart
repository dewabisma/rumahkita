import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('rules version bump clears drafting ceremony signoffs', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: uuid.v4(),
            rulesVersion: const Value(1),
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: uuid.v4(),
            status: CycleStatus.drafting.wireValue,
            ceremonySignoffs: const Value('{"member-1":{"accepted":true}}'),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    await harness.apply(
      SyncOperation(
        opId: uuid.v4(),
        opType: SyncOpType.houseRulesVersionUpdate.wireValue,
        houseId: houseId,
        originDeviceId: harness.deviceId,
        hlc: base64Encode(harness.hlcService.toBytes(harness.hlcService.now())),
        payload: {'rules_version': 2},
      ),
      houseId,
    );

    final cycle = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingle();
    expect(cycle.ceremonySignoffs, '{}');
    expect(cycle.rulesVersionAtSignoff, 2);
  });

  test('task points change clears drafting ceremony signoffs', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final taskId = uuid.v4();

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: uuid.v4(),
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: uuid.v4(),
            status: CycleStatus.drafting.wireValue,
            ceremonySignoffs: const Value('{"member-1":{"accepted":true}}'),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.tasksSync).insert(
          TasksSyncCompanion.insert(
            taskId: taskId,
            houseId: houseId,
            cycleId: cycleId,
            title: 'Dishes',
            negotiatedPoints: 10,
            status: 'open',
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    await harness.apply(
      SyncOperation(
        opId: uuid.v4(),
        opType: SyncOpType.taskFieldUpdate.wireValue,
        houseId: houseId,
        originDeviceId: harness.deviceId,
        hlc: base64Encode(harness.hlcService.toBytes(harness.hlcService.now())),
        payload: {
          'task_id': taskId,
          'field': 'negotiated_points',
          'value': 20,
        },
      ),
      houseId,
    );

    final cycle = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .getSingle();
    expect(cycle.ceremonySignoffs, '{}');
  });
}
