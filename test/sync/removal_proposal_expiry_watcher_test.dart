import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:rumah/sync/removal_proposal_expiry_watcher.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('RemovalProposalExpiryWatcher rejects expired proposals', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'expired-proposal';
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

    final now = harness.hlcService.now();
    final expiredEnds = HybridLogicalClock(
      l: now.l - const Duration(days: 8).inMilliseconds,
      c: now.c,
    );

    await harness.db.into(harness.db.removalProposalsSync).insert(
          RemovalProposalsSyncCompanion.insert(
            proposalId: proposalId,
            houseId: houseId,
            targetMemberId: memberB,
            proposerMemberId: Value(memberA),
            type: ProposalType.eviction.wireValue,
            status: ProposalStatus.proposed.wireValue,
            createdAtHlc: harness.hlcService.toBytes(expiredEnds),
            updatedAtHlc: harness.hlcService.toBytes(expiredEnds),
            votingWindowEndsAtHlc: Value(harness.hlcService.toBytes(expiredEnds)),
          ),
        );

    await harness.setActiveHouse(houseId);

    await runRemovalProposalExpiryPoll(
      houseId: houseId,
      db: harness.db,
      sync: harness.syncCoordinator,
      hlcService: harness.hlcService,
    );

    final row = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(row.status, ProposalStatus.rejected.wireValue);
  });
}
