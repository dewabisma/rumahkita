import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/domain/enums/redemption_status.dart';
import 'package:rumah/sync/privilege_redeem_ids.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('repository redeemPrivilege applies paired redemption and score ops', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 25;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final repo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    final redemption = await repo.redeemPrivilege(
      houseId: houseId,
      cycleId: cycleId,
      privilegeId: privilegeId,
      memberId: memberId,
    );

    final redemptionId = privilegeRedemptionId(
      houseId: houseId,
      memberId: memberId,
      privilegeId: privilegeId,
      cycleId: cycleId,
    );
    expect(redemption.redemptionId, redemptionId);
    expect(redemption.status, RedemptionStatus.active);

    final scoreEventId = privilegeRedeemScoreEventId(
      houseId: houseId,
      memberId: memberId,
      redemptionId: redemptionId,
      purchaseIndex: 0,
    );
    final scoreRow = await (harness.db.select(harness.db.scoreEvents)
          ..where((t) => t.eventId.equals(scoreEventId)))
        .getSingleOrNull();
    expect(scoreRow, isNotNull);
    expect(scoreRow!.delta, -pointCost);

    final member = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();
    expect(member.lifetimeScore, 25);
  });

  test('redemption create deducts points via score event', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 25;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );

    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final redemptionId = privilegeRedemptionId(
      houseId: houseId,
      memberId: memberId,
      privilegeId: privilegeId,
      cycleId: cycleId,
    );

    final redeemResult = await harness.apply(
      harness.privilegeRedemptionCreate(
        opId: uuid.v4(),
        houseId: houseId,
        redemptionId: redemptionId,
        memberId: memberId,
        privilegeId: privilegeId,
        cycleId: cycleId,
        pointCost: pointCost,
      ),
      houseId,
    );
    expect(redeemResult.appliedOpIds.length, 1);

    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: privilegeRedeemScoreEventId(
          houseId: houseId,
          memberId: memberId,
          redemptionId: redemptionId,
          purchaseIndex: 0,
        ),
        memberId: memberId,
        delta: -pointCost,
        reasonRef: privilegeRedeemReasonRef(redemptionId),
      ),
      houseId,
    );

    final member = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();
    expect(member.lifetimeScore, 25);

    final redemption = await (harness.db.select(
      harness.db.privilegeRedemptionEvents,
    )..where((t) => t.redemptionId.equals(redemptionId))).getSingle();
    expect(redemption.pointCost, pointCost);
    expect(redemption.status, 'active');

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.action.equals('privilege_redeemed')))
        .get();
    expect(audits.length, 1);
  });

  test('redemption rejected when cycle not active', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
      status: 'drafting',
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
    );

    final result = await harness.apply(
      harness.privilegeRedemptionCreate(
        opId: uuid.v4(),
        houseId: houseId,
        redemptionId: uuid.v4(),
        memberId: memberId,
        privilegeId: privilegeId,
        cycleId: cycleId,
        pointCost: 10,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('redemption rejected when projected balance is insufficient', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 25;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 10,
      ),
      houseId,
    );

    final result = await harness.apply(
      harness.privilegeRedemptionCreate(
        opId: uuid.v4(),
        houseId: houseId,
        redemptionId: uuid.v4(),
        memberId: memberId,
        privilegeId: privilegeId,
        cycleId: cycleId,
        pointCost: pointCost,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('redemption rejected when payload point_cost mismatches catalog', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: 20,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final result = await harness.apply(
      harness.privilegeRedemptionCreate(
        opId: uuid.v4(),
        houseId: houseId,
        redemptionId: uuid.v4(),
        memberId: memberId,
        privilegeId: privilegeId,
        cycleId: cycleId,
        pointCost: 99,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('duplicate active redemption is rejected at merge', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 15;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final redemptionId = privilegeRedemptionId(
      houseId: houseId,
      memberId: memberId,
      privilegeId: privilegeId,
      cycleId: cycleId,
    );

    final first = await harness.apply(
      harness.privilegeRedemptionCreate(
        opId: uuid.v4(),
        houseId: houseId,
        redemptionId: redemptionId,
        memberId: memberId,
        privilegeId: privilegeId,
        cycleId: cycleId,
        pointCost: pointCost,
      ),
      houseId,
    );
    expect(first.appliedOpIds.length, 1);

    final duplicate = await harness.apply(
      harness.privilegeRedemptionCreate(
        opId: uuid.v4(),
        houseId: houseId,
        redemptionId: redemptionId,
        memberId: memberId,
        privilegeId: privilegeId,
        cycleId: cycleId,
        pointCost: pointCost,
      ),
      houseId,
    );
    expect(duplicate.rejectedOpIds.length, 1);
  });

  test('repository rejects duplicate redeem before emit', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 15;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final repo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    await repo.redeemPrivilege(
      houseId: houseId,
      cycleId: cycleId,
      privilegeId: privilegeId,
      memberId: memberId,
    );

    expect(
      () => repo.redeemPrivilege(
        houseId: houseId,
        cycleId: cycleId,
        privilegeId: privilegeId,
        memberId: memberId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('consumeRedemption marks one-shot entitlement consumed', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 10;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final repo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    final redemption = await repo.redeemPrivilege(
      houseId: houseId,
      cycleId: cycleId,
      privilegeId: privilegeId,
      memberId: memberId,
    );

    await repo.consumeRedemption(
      houseId: houseId,
      redemptionId: redemption.redemptionId,
      actorMemberId: memberId,
    );

    final row = await (harness.db.select(harness.db.privilegeRedemptionEvents)
          ..where((t) => t.redemptionId.equals(redemption.redemptionId)))
        .getSingle();
    expect(row.status, RedemptionStatus.consumed.wireValue);
  });

  test('paired batch rejects score when redemption fails in same batch', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 25;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 10,
      ),
      houseId,
    );

    final redemptionId = privilegeRedemptionId(
      houseId: houseId,
      memberId: memberId,
      privilegeId: privilegeId,
      cycleId: cycleId,
    );
    final reasonRef = privilegeRedeemReasonRef(redemptionId);

    final result = await harness.applyBatch(
      [
        harness.privilegeRedemptionCreate(
          opId: uuid.v4(),
          houseId: houseId,
          redemptionId: redemptionId,
          memberId: memberId,
          privilegeId: privilegeId,
          cycleId: cycleId,
          pointCost: pointCost,
        ),
        harness.scoreEvent(
          opId: uuid.v4(),
          houseId: houseId,
          eventId: privilegeRedeemScoreEventId(
            houseId: houseId,
            memberId: memberId,
            redemptionId: redemptionId,
            purchaseIndex: 0,
          ),
          memberId: memberId,
          delta: -pointCost,
          reasonRef: reasonRef,
        ),
      ],
      houseId,
    );

    expect(result.rejectedOpIds.length, 2);

    final member = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();
    expect(member.lifetimeScore, 10);

    final redemptionCount = await (harness.db.select(
      harness.db.privilegeRedemptionEvents,
    )).get();
    expect(redemptionCount, isEmpty);
  });

  test('one-shot perk can be re-redeemed after consume', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();
    const memberId = 'member-a';
    const pointCost = 10;

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: memberId,
    );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
      usageMode: 'one_shot',
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 50,
      ),
      houseId,
    );

    final repo = DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    );
    final first = await repo.redeemPrivilege(
      houseId: houseId,
      cycleId: cycleId,
      privilegeId: privilegeId,
      memberId: memberId,
    );
    await repo.consumeRedemption(
      houseId: houseId,
      redemptionId: first.redemptionId,
      actorMemberId: memberId,
    );

    final second = await repo.redeemPrivilege(
      houseId: houseId,
      cycleId: cycleId,
      privilegeId: privilegeId,
      memberId: memberId,
    );

    expect(second.redemptionId, first.redemptionId);
    expect(second.status, RedemptionStatus.active);

    final redemptionId = first.redemptionId;
    final allPurchases = await (harness.db.select(harness.db.scoreEvents)
          ..where((t) => t.memberId.equals(memberId)))
        .get();
    final purchases = allPurchases
        .where(
          (e) => e.reasonRef == privilegeRedeemReasonRef(redemptionId),
        )
        .toList();
    expect(purchases.length, 2);
    expect(purchases.every((e) => e.delta == -pointCost), isTrue);

    final member = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();
    expect(member.lifetimeScore, 30);
  });
}
