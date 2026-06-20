import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/repositories/removal_repository.dart';
import 'package:rumah/sync/removal_op_ids.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('majority yes votes advance proposed to ready_to_execute', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'proposal-1';
    const memberA = 'member-a';
    const memberB = 'member-b';
    const memberC = 'member-c';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);
    await harness.seedHousemate(houseId: houseId, memberId: memberB);
    await harness.seedHousemate(houseId: houseId, memberId: memberC);

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: memberC,
      ),
      houseId,
    );

    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: 'vote-a',
        proposalId: proposalId,
        voterMemberId: memberA,
        voteCast: true,
      ),
      houseId,
    );
    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: 'vote-b',
        proposalId: proposalId,
        voterMemberId: memberB,
        voteCast: true,
      ),
      houseId,
    );

    final row = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(row.status, ProposalStatus.readyToExecute.wireValue);

    final appliedIds = await (harness.db.select(harness.db.syncAppliedOps)).get();
    expect(
      appliedIds.any((a) => a.opId == removalApprovedOpId(proposalId)),
      isTrue,
    );
    expect(
      appliedIds.any((a) => a.opId == removalReadyOpId(proposalId)),
      isTrue,
    );
  });

  test('vote flip below threshold rejects proposal', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'proposal-flip';
    const memberA = 'member-a';
    const memberB = 'member-b';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);
    await harness.seedHousemate(houseId: houseId, memberId: memberB);

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: memberB,
      ),
      houseId,
    );

    final ctxAfterCreate = await harness.contextFor(houseId);
    final yesResult = await harness.mergeEngine.applyOps(
      [
        harness.voteCast(
          opId: uuid.v4(),
          houseId: houseId,
          voteId: 'vote-a-yes',
          proposalId: proposalId,
          voterMemberId: memberA,
          voteCast: true,
        ),
      ],
      ctxAfterCreate,
    );
    // Do not run side effects — keep status proposed at threshold.
    expect(yesResult.appliedOpIds, isNotEmpty);

    final ctxAfterYes = await harness.contextFor(houseId);
    final flipResult = await harness.mergeEngine.applyOps(
      [
        harness.voteCast(
          opId: uuid.v4(),
          houseId: houseId,
          voteId: 'vote-a-no',
          proposalId: proposalId,
          voterMemberId: memberA,
          voteCast: false,
        ),
      ],
      ctxAfterYes,
    );
    await harness.sideEffectHandler.handle(flipResult.sideEffects);

    final row = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(row.status, ProposalStatus.rejected.wireValue);
  });

  test('self-removal shortcut reaches ready_to_execute', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'self-removal-1';
    const memberA = 'member-a';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: memberA,
        type: ProposalType.selfRemoval,
      ),
      houseId,
    );
    await harness.apply(
      harness.proposalStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        from: ProposalStatus.proposed,
        to: ProposalStatus.readyToExecute,
      ),
      houseId,
    );

    final row = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(row.status, ProposalStatus.readyToExecute.wireValue);
  });

  test('one yes one no one undecided stays proposed in four-member house', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'proposal-undecided';
    const memberA = 'member-a';
    const memberB = 'member-b';
    const memberC = 'member-c';
    const memberD = 'member-d';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);
    await harness.seedHousemate(houseId: houseId, memberId: memberB);
    await harness.seedHousemate(houseId: houseId, memberId: memberC);
    await harness.seedHousemate(houseId: houseId, memberId: memberD);

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: memberD,
        proposerMemberId: memberA,
      ),
      houseId,
    );

    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: 'vote-a',
        proposalId: proposalId,
        voterMemberId: memberA,
        voteCast: true,
      ),
      houseId,
    );
    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: 'vote-b',
        proposalId: proposalId,
        voterMemberId: memberB,
        voteCast: false,
      ),
      houseId,
    );

    final row = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(row.status, ProposalStatus.proposed.wireValue);
  });

  test('propose eviction persists justification in audit log', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const memberA = 'member-a';
    const memberB = 'member-b';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);
    await harness.seedHousemate(houseId: houseId, memberId: memberB);

    final proposal = await harness.removalRepository.proposeEviction(
      houseId: houseId,
      proposerMemberId: memberA,
      targetMemberId: memberB,
      justificationNotes: 'Repeated missed chores',
    );

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.taskId.equals(proposal.proposalId)))
        .get();
    expect(audits, isNotEmpty);
    expect(
      audits.any(
        (a) =>
            a.action == 'removal_proposal_created' &&
            a.justificationNotes == 'Repeated missed chores',
      ),
      isTrue,
    );
  });

  test('guardian eviction is blocked during live cycle', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const guardian = 'guardian-member';
    const proposer = 'proposer-member';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: proposer,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: proposer);
    await harness.seedHousemate(houseId: houseId, memberId: guardian);
    await harness.seedCycle(
      houseId: houseId,
      cycleId: 'cycle-1',
      guardianMemberId: guardian,
      status: CycleStatus.active.wireValue,
    );

    await expectLater(
      harness.removalRepository.proposeEviction(
        houseId: houseId,
        proposerMemberId: proposer,
        targetMemberId: guardian,
      ),
      throwsA(isA<GuardianEvictionBlockedException>()),
    );
  });

  test('cancelProposal transitions proposed removal to cancelled', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'cancel-proposal';
    const memberA = 'member-a';
    const memberB = 'member-b';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberA);
    await harness.seedHousemate(houseId: houseId, memberId: memberB);

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: memberB,
        proposerMemberId: memberA,
      ),
      houseId,
    );

    await harness.removalRepository.cancelProposal(
      houseId: houseId,
      proposalId: proposalId,
      actorMemberId: memberA,
    );

    final row = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(row.status, ProposalStatus.cancelled.wireValue);
  });
}
