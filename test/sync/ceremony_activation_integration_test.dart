import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/ceremony_guardian.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('local unanimous accept activates cycle with guardian', () async {
    final seed = await _seedDraftingHouse(await SyncTestHarness.create());
    final ceremonyRepo = DriftCeremonyRepository(
      db: seed.harness.db,
      sync: seed.harness.syncCoordinator,
    );

    await ceremonyRepo.acceptRules(
      houseId: seed.houseId,
      cycleId: seed.cycleId,
      memberId: seed.memberA,
    );

    final cycle = await (seed.harness.db.select(
      seed.harness.db.cyclesSync,
    )..where((t) => t.cycleId.equals(seed.cycleId))).getSingle();
    expect(cycle.status, CycleStatus.active.wireValue);
    expect(
      cycle.activeGuardianMemberId,
      pickDeterministicGuardian(seed.cycleId, [seed.memberA]),
    );
  });

  test(
    'two-member offline accept sync activates cycle on both peers',
    () async {
      final peerA = await SyncTestHarness.create(
        deviceId: 'device-a',
        nodeKey: 'node-a',
      );
      final peerB = await SyncTestHarness.create(
        deviceId: 'device-b',
        nodeKey: 'node-b',
      );
      const uuid = Uuid();
      final houseId = uuid.v4();
      final cycleId = uuid.v4();
      final memberA = uuid.v4();
      final memberB = uuid.v4();

      for (final harness in [peerA, peerB]) {
        await harness.db
            .into(harness.db.houseSync)
            .insert(
              HouseSyncCompanion.insert(
                houseId: houseId,
                displayName: 'Shared Home',
                creatorMemberId: memberA,
                createdAtHlc: harness.hlcService.toBytes(
                  harness.hlcService.now(),
                ),
                updatedAtHlc: harness.hlcService.toBytes(
                  harness.hlcService.now(),
                ),
              ),
            );
        await harness.db
            .into(harness.db.housematesSync)
            .insert(
              HousematesSyncCompanion.insert(
                memberId: memberA,
                houseId: houseId,
                tailscaleUserId: 'user-a',
                tailscaleNodeKey: peerA.nodeKey,
                nickname: 'A',
                memberStatus: MemberStatus.active.wireValue,
                updatedAtHlc: harness.hlcService.toBytes(
                  harness.hlcService.now(),
                ),
              ),
            );
        await harness.db
            .into(harness.db.housematesSync)
            .insert(
              HousematesSyncCompanion.insert(
                memberId: memberB,
                houseId: houseId,
                tailscaleUserId: 'user-b',
                tailscaleNodeKey: peerB.nodeKey,
                nickname: 'B',
                memberStatus: MemberStatus.active.wireValue,
                updatedAtHlc: harness.hlcService.toBytes(
                  harness.hlcService.now(),
                ),
              ),
            );
        await harness.db
            .into(harness.db.cyclesSync)
            .insert(
              CyclesSyncCompanion.insert(
                cycleId: cycleId,
                houseId: houseId,
                activeGuardianMemberId: memberA,
                status: CycleStatus.drafting.wireValue,
                updatedAtHlc: harness.hlcService.toBytes(
                  harness.hlcService.now(),
                ),
              ),
            );
      }

      final repoA = DriftCeremonyRepository(
        db: peerA.db,
        sync: peerA.syncCoordinator,
      );
      final repoB = DriftCeremonyRepository(
        db: peerB.db,
        sync: peerB.syncCoordinator,
      );

      await repoA.acceptRules(
        houseId: houseId,
        cycleId: cycleId,
        memberId: memberA,
      );
      await repoB.acceptRules(
        houseId: houseId,
        cycleId: cycleId,
        memberId: memberB,
      );

      await _relayOutboxes(peerA, peerB);
      await _relayOutboxes(peerB, peerA);

      for (final harness in [peerA, peerB]) {
        final cycle = await (harness.db.select(
          harness.db.cyclesSync,
        )..where((t) => t.cycleId.equals(cycleId))).getSingle();
        expect(cycle.status, CycleStatus.active.wireValue);
        expect(
          cycle.activeGuardianMemberId,
          pickDeterministicGuardian(cycleId, [memberA, memberB]),
        );
      }
    },
  );

  test(
    'inbound signoff merge triggers activation without local accept',
    () async {
      final peerA = await SyncTestHarness.create(
        deviceId: 'device-a',
        nodeKey: 'node-a',
      );
      final peerB = await SyncTestHarness.create(
        deviceId: 'device-b',
        nodeKey: 'node-b',
      );
      const uuid = Uuid();
      final houseId = uuid.v4();
      final cycleId = uuid.v4();
      final memberA = uuid.v4();
      final memberB = uuid.v4();

      for (final harness in [peerA, peerB]) {
        await _insertTwoMemberDraftingHouse(
          harness: harness,
          houseId: houseId,
          cycleId: cycleId,
          memberA: memberA,
          memberB: memberB,
          nodeKeyA: peerA.nodeKey,
          nodeKeyB: peerB.nodeKey,
        );
      }

      final repoA = DriftCeremonyRepository(
        db: peerA.db,
        sync: peerA.syncCoordinator,
      );
      final repoB = DriftCeremonyRepository(
        db: peerB.db,
        sync: peerB.syncCoordinator,
      );

      await repoA.acceptRules(
        houseId: houseId,
        cycleId: cycleId,
        memberId: memberA,
      );
      await repoB.acceptRules(
        houseId: houseId,
        cycleId: cycleId,
        memberId: memberB,
      );

      expect(
        (await _cycleOn(peerA, cycleId)).status,
        CycleStatus.drafting.wireValue,
      );

      await _relayOutboxes(peerB, peerA);

      final cycleOnA = await _cycleOn(peerA, cycleId);
      expect(cycleOnA.status, CycleStatus.active.wireValue);
      expect(
        cycleOnA.activeGuardianMemberId,
        pickDeterministicGuardian(cycleId, [memberA, memberB]),
      );
    },
  );

  test('subsequent activation rotates guardian from completed cycle', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberA = uuid.v4();
    final memberB = uuid.v4();
    final memberC = uuid.v4();
    final completedCycleId = uuid.v4();
    final draftingCycleId = uuid.v4();
    final hlc = harness.hlcService.toBytes(harness.hlcService.now());

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: hlc,
            updatedAtHlc: hlc,
          ),
        );
    for (final entry in [
      (memberA, 'A', 0),
      (memberB, 'B', 1),
      (memberC, 'C', 2),
    ]) {
      await harness.db.into(harness.db.housematesSync).insert(
            HousematesSyncCompanion.insert(
              memberId: entry.$1,
              houseId: houseId,
              tailscaleUserId: 'user-${entry.$2}',
              tailscaleNodeKey: '${harness.nodeKey}-${entry.$2}',
              nickname: entry.$2,
              rotationOrderIndex: Value(entry.$3),
              memberStatus: MemberStatus.active.wireValue,
              updatedAtHlc: hlc,
            ),
          );
    }
    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: completedCycleId,
            houseId: houseId,
            activeGuardianMemberId: memberA,
            status: CycleStatus.completed.wireValue,
            updatedAtHlc: hlc,
          ),
        );
    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: draftingCycleId,
            houseId: houseId,
            activeGuardianMemberId: memberA,
            status: CycleStatus.drafting.wireValue,
            updatedAtHlc: hlc,
          ),
        );

    final ceremonyRepo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    await ceremonyRepo.acceptRules(
      houseId: houseId,
      cycleId: draftingCycleId,
      memberId: memberA,
    );
    await ceremonyRepo.acceptRules(
      houseId: houseId,
      cycleId: draftingCycleId,
      memberId: memberB,
    );
    await ceremonyRepo.acceptRules(
      houseId: houseId,
      cycleId: draftingCycleId,
      memberId: memberC,
    );

    final cycle = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(draftingCycleId)))
        .getSingle();
    expect(cycle.status, CycleStatus.active.wireValue);
    expect(
      cycle.activeGuardianMemberId,
      pickNextGuardian(
        previousGuardianId: memberA,
        activeRoster: [
          RotationRosterMember(memberId: memberA, rotationOrderIndex: 0),
          RotationRosterMember(memberId: memberB, rotationOrderIndex: 1),
          RotationRosterMember(memberId: memberC, rotationOrderIndex: 2),
        ],
        previousGuardianRotationIndex: 0,
      ),
    );
    expect(cycle.activeGuardianMemberId, memberB);
  });

  test('null rotation index blocks second-cycle activation', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberA = uuid.v4();
    final memberB = uuid.v4();
    final completedCycleId = uuid.v4();
    final draftingCycleId = uuid.v4();
    final hlc = harness.hlcService.toBytes(harness.hlcService.now());

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: hlc,
            updatedAtHlc: hlc,
          ),
        );
    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: memberA,
            houseId: houseId,
            tailscaleUserId: 'user-a',
            tailscaleNodeKey: '${harness.nodeKey}-a',
            nickname: 'A',
            rotationOrderIndex: const Value(0),
            memberStatus: MemberStatus.active.wireValue,
            updatedAtHlc: hlc,
          ),
        );
    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: memberB,
            houseId: houseId,
            tailscaleUserId: 'user-b',
            tailscaleNodeKey: '${harness.nodeKey}-b',
            nickname: 'B',
            memberStatus: MemberStatus.active.wireValue,
            updatedAtHlc: hlc,
          ),
        );
    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: completedCycleId,
            houseId: houseId,
            activeGuardianMemberId: memberA,
            status: CycleStatus.completed.wireValue,
            updatedAtHlc: hlc,
          ),
        );
    await harness.db.into(harness.db.cyclesSync).insert(
          CyclesSyncCompanion.insert(
            cycleId: draftingCycleId,
            houseId: houseId,
            activeGuardianMemberId: memberA,
            status: CycleStatus.drafting.wireValue,
            updatedAtHlc: hlc,
          ),
        );

    final ceremonyRepo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    await ceremonyRepo.acceptRules(
      houseId: houseId,
      cycleId: draftingCycleId,
      memberId: memberA,
    );
    await ceremonyRepo.acceptRules(
      houseId: houseId,
      cycleId: draftingCycleId,
      memberId: memberB,
    );

    final cycle = await (harness.db.select(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(draftingCycleId)))
        .getSingle();
    expect(cycle.status, CycleStatus.drafting.wireValue);
  });

  test(
    'concurrent cycleCreate rejects duplicate drafting cycle on merge',
    () async {
      final peerA = await SyncTestHarness.create(deviceId: 'device-a');
      const uuid = Uuid();
      final houseId = uuid.v4();
      final memberA = uuid.v4();
      final cycleA = uuid.v4();
      final cycleB = uuid.v4();

      await peerA.db
          .into(peerA.db.houseSync)
          .insert(
            HouseSyncCompanion.insert(
              houseId: houseId,
              displayName: 'Home',
              creatorMemberId: memberA,
              createdAtHlc: peerA.hlcService.toBytes(peerA.hlcService.now()),
              updatedAtHlc: peerA.hlcService.toBytes(peerA.hlcService.now()),
            ),
          );
      await peerA.db
          .into(peerA.db.housematesSync)
          .insert(
            HousematesSyncCompanion.insert(
              memberId: memberA,
              houseId: houseId,
              tailscaleUserId: 'user-a',
              tailscaleNodeKey: peerA.nodeKey,
              nickname: 'A',
              memberStatus: MemberStatus.active.wireValue,
              updatedAtHlc: peerA.hlcService.toBytes(peerA.hlcService.now()),
            ),
          );
      await peerA.db
          .into(peerA.db.cyclesSync)
          .insert(
            CyclesSyncCompanion.insert(
              cycleId: cycleA,
              houseId: houseId,
              activeGuardianMemberId: memberA,
              status: CycleStatus.drafting.wireValue,
              updatedAtHlc: peerA.hlcService.toBytes(peerA.hlcService.now()),
            ),
          );

      final result = await peerA.apply(
        SyncOperation(
          opId: uuid.v4(),
          opType: SyncOpType.cycleCreate.wireValue,
          houseId: houseId,
          originDeviceId: 'device-b',
          hlc: base64Encode(peerA.hlcService.toBytes(peerA.hlcService.now())),
          payload: {
            'cycle_id': cycleB,
            'active_guardian_member_id': memberA,
            'status': CycleStatus.drafting.wireValue,
          },
        ),
        houseId,
      );

      expect(result.rejectedOpIds, isNotEmpty);

      final drafting =
          await (peerA.db.select(peerA.db.cyclesSync)..where(
                (t) =>
                    t.houseId.equals(houseId) &
                    t.status.equals(CycleStatus.drafting.wireValue),
              ))
              .get();
      expect(drafting.length, 1);
      expect(drafting.single.cycleId, cycleA);
    },
  );
}

Future<void> _relayOutboxes(SyncTestHarness from, SyncTestHarness to) async {
  final outbox = await from.db.select(from.db.syncOutboxEntries).get();
  outbox.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
  for (final row in outbox) {
    final envelope = SyncEnvelope.fromJson(
      jsonDecode(row.envelopeJson) as Map<String, dynamic>,
    );
    await to.syncCoordinator.ingestEnvelope(envelope);
  }
}

Future<CyclesSyncData> _cycleOn(SyncTestHarness harness, String cycleId) {
  return (harness.db.select(
    harness.db.cyclesSync,
  )..where((t) => t.cycleId.equals(cycleId))).getSingle();
}

Future<void> _insertTwoMemberDraftingHouse({
  required SyncTestHarness harness,
  required String houseId,
  required String cycleId,
  required String memberA,
  required String memberB,
  required String nodeKeyA,
  required String nodeKeyB,
}) async {
  await harness.db
      .into(harness.db.houseSync)
      .insert(
        HouseSyncCompanion.insert(
          houseId: houseId,
          displayName: 'Shared Home',
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
          tailscaleNodeKey: nodeKeyA,
          nickname: 'A',
          memberStatus: MemberStatus.active.wireValue,
          updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
        ),
      );
  await harness.db
      .into(harness.db.housematesSync)
      .insert(
        HousematesSyncCompanion.insert(
          memberId: memberB,
          houseId: houseId,
          tailscaleUserId: 'user-b',
          tailscaleNodeKey: nodeKeyB,
          nickname: 'B',
          memberStatus: MemberStatus.active.wireValue,
          updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
        ),
      );
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

Future<_DraftingSeed> _seedDraftingHouse(SyncTestHarness harness) async {
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

  return _DraftingSeed(
    harness: harness,
    houseId: houseId,
    cycleId: cycleId,
    memberA: memberA,
  );
}
