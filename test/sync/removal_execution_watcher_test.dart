import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:rumah/services/stub_tailscale_admin_api.dart';
import 'package:rumah/sync/removal_execution_watcher.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('RemovalExecutionWatcher poll executes ready proposal end-to-end', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const proposalId = 'exec-proposal';
    const memberA = 'member-a';
    const nodeA = 'node-a';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberA,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: memberA,
            houseId: houseId,
            tailscaleUserId: 'user-a',
            tailscaleNodeKey: nodeA,
            nickname: 'A',
            memberStatus: MemberStatus.active.wireValue,
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.syncPeerAllowlist).insert(
          SyncPeerAllowlistCompanion.insert(
            tailscaleNodeKey: nodeA,
            houseId: houseId,
            memberId: Value(memberA),
          ),
        );
    await harness.db.into(harness.db.removalProposalsSync).insert(
          RemovalProposalsSyncCompanion.insert(
            proposalId: proposalId,
            houseId: houseId,
            targetMemberId: memberA,
            type: ProposalType.selfRemoval.wireValue,
            status: ProposalStatus.readyToExecute.wireValue,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final tailscaleAdmin = StubTailscaleAdminApi();
    await harness.setActiveHouse(houseId);

    await runRemovalExecutionPoll(
      houseId: houseId,
      db: harness.db,
      sync: harness.syncCoordinator,
      tailscaleAdmin: tailscaleAdmin,
      localSettings: harness.localSettingsRepository,
    );

    final proposal = await (harness.db.select(harness.db.removalProposalsSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .getSingle();
    expect(proposal.status, ProposalStatus.executed.wireValue);

    final member = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(memberA)))
        .getSingle();
    expect(member.memberStatus, MemberStatus.evicted.wireValue);

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.action.equals('removal_executed')))
        .get();
    expect(audits, isNotEmpty);
    expect(tailscaleAdmin.invalidations, hasLength(1));
    expect(tailscaleAdmin.invalidations.first.nodeKey, nodeA);
  });
}
