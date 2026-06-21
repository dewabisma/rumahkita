import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/ceremony_guardian.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('rules version bump clears drafting ceremony signoffs', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();

    await harness.db
        .into(harness.db.houseSync)
        .insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: uuid.v4(),
            rulesVersion: const Value(1),
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db
        .into(harness.db.cyclesSync)
        .insert(
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

    final cycle = await (harness.db.select(
      harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingle();
    expect(cycle.ceremonySignoffs, '{}');
    expect(cycle.rulesVersionAtSignoff, 2);
  });

  test('task points change clears drafting ceremony signoffs', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final taskId = uuid.v4();

    await harness.db
        .into(harness.db.houseSync)
        .insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: uuid.v4(),
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db
        .into(harness.db.cyclesSync)
        .insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: uuid.v4(),
            status: CycleStatus.drafting.wireValue,
            ceremonySignoffs: const Value('{"member-1":{"accepted":true}}'),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db
        .into(harness.db.tasksSync)
        .insert(
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
        payload: {'task_id': taskId, 'field': 'negotiated_points', 'value': 20},
      ),
      houseId,
    );

    final cycle = await (harness.db.select(
      harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(cycleId))).getSingle();
    expect(cycle.ceremonySignoffs, '{}');
  });

  test('task create bumps rules version and clears signoffs', () async {
    final seed = await _seedDraftingHouse(await SyncTestHarness.create());
    final ceremonyRepo = DriftCeremonyRepository(
      db: seed.harness.db,
      sync: seed.harness.syncCoordinator,
    );

    await ceremonyRepo.addTask(
      houseId: seed.houseId,
      cycleId: seed.cycleId,
      title: 'Laundry',
      description: 'Weekly laundry run',
      points: 15,
      actorMemberId: seed.memberA,
    );

    final house = await (seed.harness.db.select(
      seed.harness.db.houseSync,
    )..where((t) => t.houseId.equals(seed.houseId))).getSingle();
    expect(house.rulesVersion, 1);

    final cycle = await (seed.harness.db.select(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).getSingle();
    expect(cycle.ceremonySignoffs, '{}');
    expect(cycle.rulesVersionAtSignoff, 1);
  });

  test('task title change bumps rules version and clears signoffs', () async {
    final seed = await _seedDraftingHouse(await SyncTestHarness.create());
    final ceremonyRepo = DriftCeremonyRepository(
      db: seed.harness.db,
      sync: seed.harness.syncCoordinator,
    );
    const uuid = Uuid();
    final taskId = uuid.v4();

    await seed.harness.db
        .into(seed.harness.db.tasksSync)
        .insert(
          TasksSyncCompanion.insert(
            taskId: taskId,
            houseId: seed.houseId,
            cycleId: seed.cycleId,
            title: 'Dishes',
            negotiatedPoints: 10,
            status: 'open',
            updatedAtHlc: seed.harness.hlcService.toBytes(
              seed.harness.hlcService.now(),
            ),
          ),
        );
    await (seed.harness.db.update(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).write(
      const CyclesSyncCompanion(
        ceremonySignoffs: Value('{"member-a":{"accepted":true}}'),
      ),
    );

    await ceremonyRepo.updateTaskTitle(
      houseId: seed.houseId,
      taskId: taskId,
      title: 'Dishes & pans',
      actorMemberId: seed.memberA,
    );

    final cycle = await (seed.harness.db.select(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).getSingle();
    expect(cycle.ceremonySignoffs, '{}');
    expect(cycle.rulesVersionAtSignoff, 1);
  });

  test('archive task bumps rules version and clears signoffs', () async {
    final seed = await _seedDraftingHouse(await SyncTestHarness.create());
    final ceremonyRepo = DriftCeremonyRepository(
      db: seed.harness.db,
      sync: seed.harness.syncCoordinator,
    );
    const uuid = Uuid();
    final taskId = uuid.v4();

    await seed.harness.db
        .into(seed.harness.db.tasksSync)
        .insert(
          TasksSyncCompanion.insert(
            taskId: taskId,
            houseId: seed.houseId,
            cycleId: seed.cycleId,
            title: 'Trash',
            negotiatedPoints: 5,
            status: 'open',
            updatedAtHlc: seed.harness.hlcService.toBytes(
              seed.harness.hlcService.now(),
            ),
          ),
        );
    await (seed.harness.db.update(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).write(
      const CyclesSyncCompanion(
        ceremonySignoffs: Value('{"member-a":{"accepted":true}}'),
      ),
    );

    await ceremonyRepo.archiveTask(
      houseId: seed.houseId,
      taskId: taskId,
      actorMemberId: seed.memberA,
    );

    final task = await (seed.harness.db.select(
      seed.harness.db.tasksSync,
    )..where((t) => t.taskId.equals(taskId))).getSingle();
    expect(task.status, TaskStatus.archived.wireValue);

    final cycle = await (seed.harness.db.select(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).getSingle();
    expect(cycle.ceremonySignoffs, '{}');
  });

  test(
    'new member joins during drafting clears signoffs via rules bump',
    () async {
      final seed = await _seedDraftingHouse(await SyncTestHarness.create());
      await (seed.harness.db.update(
        seed.harness.db.cyclesSync,
      )..where((t) => t.cycleId.equals(seed.cycleId))).write(
        const CyclesSyncCompanion(
          ceremonySignoffs: Value('{"member-a":{"accepted":true}}'),
        ),
      );

      const uuid = Uuid();
      final memberB = uuid.v4();
      await seed.harness.housemateRepository.joinHousemate(
        houseId: seed.houseId,
        memberId: memberB,
        tailscaleUserId: 'user-b',
        tailscaleNodeKey: 'node-b',
        nickname: 'B',
        rotationOrderIndex: 1,
      );

      final cycle = await (seed.harness.db.select(
        seed.harness.db.cyclesSync,
      )..where((t) => t.cycleId.equals(seed.cycleId))).getSingle();
      expect(cycle.ceremonySignoffs, '{}');
      expect(cycle.rulesVersionAtSignoff, 1);

      final house = await (seed.harness.db.select(
        seed.harness.db.houseSync,
      )..where((t) => t.houseId.equals(seed.houseId))).getSingle();
      expect(house.rulesVersion, 1);
    },
  );

  test('activation rejected when rulesVersionAtSignoff is stale', () async {
    final seed = await _seedDraftingHouse(await SyncTestHarness.create());
    final ceremonyRepo = DriftCeremonyRepository(
      db: seed.harness.db,
      sync: seed.harness.syncCoordinator,
    );

    await (seed.harness.db.update(seed.harness.db.houseSync)
          ..where((t) => t.houseId.equals(seed.houseId)))
        .write(const HouseSyncCompanion(rulesVersion: Value(3)));

    await ceremonyRepo.acceptRules(
      houseId: seed.houseId,
      cycleId: seed.cycleId,
      memberId: seed.memberA,
    );

    final cycle = await (seed.harness.db.select(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).getSingle();
    expect(cycle.status, CycleStatus.drafting.wireValue);
  });

  test('concurrent cycleCreate yields one drafting cycle', () async {
    final seed = await _seedDraftingHouse(
      await SyncTestHarness.create(),
      withCycle: false,
    );
    final ceremonyRepo = DriftCeremonyRepository(
      db: seed.harness.db,
      sync: seed.harness.syncCoordinator,
    );

    final first = await ceremonyRepo.startCeremony(seed.houseId);
    final second = await ceremonyRepo.startCeremony(seed.houseId);

    expect(first.cycleId, second.cycleId);

    final cycles =
        await (seed.harness.db.select(seed.harness.db.cyclesSync)..where(
              (t) =>
                  t.houseId.equals(seed.houseId) &
                  t.status.equals(CycleStatus.drafting.wireValue),
            ))
            .get();
    expect(cycles.length, 1);
  });

  test('deterministic guardian selection', () {
    const cycleId = 'fixed-cycle-id-1234';
    final members = ['charlie', 'alice', 'bob'];
    final guardian = pickDeterministicGuardian(cycleId, members);
    expect(guardian, pickDeterministicGuardian(cycleId, members));
    expect(members, contains(guardian));
  });
}

class _DraftingSeed {
  const _DraftingSeed({
    required this.harness,
    required this.houseId,
    required this.cycleId,
    required this.memberA,
  });

  final SyncTestHarness harness;
  final String houseId;
  final String cycleId;
  final String memberA;
}

Future<_DraftingSeed> _seedDraftingHouse(
  SyncTestHarness harness, {
  bool withCycle = true,
}) async {
  const uuid = Uuid();
  final houseId = uuid.v4();
  final memberA = uuid.v4();
  final cycleId = uuid.v4();

  await harness.db
      .into(harness.db.houseSync)
      .insert(
        HouseSyncCompanion.insert(
          houseId: houseId,
          displayName: 'Home',
          creatorMemberId: memberA,
          createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
        ),
      );
  await harness.db
      .into(harness.db.housematesSync)
      .insert(
        HousematesSyncCompanion.insert(
          memberId: memberA,
          houseId: houseId,
          tailscaleUserId: 'user-a',
          tailscaleNodeKey: harness.nodeKey,
          nickname: 'A',
          memberStatus: MemberStatus.active.wireValue,
          updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
        ),
      );

  if (withCycle) {
    await harness.db
        .into(harness.db.cyclesSync)
        .insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: memberA,
            status: CycleStatus.drafting.wireValue,
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
  }

  return _DraftingSeed(
    harness: harness,
    houseId: houseId,
    cycleId: cycleId,
    memberA: memberA,
  );
}
