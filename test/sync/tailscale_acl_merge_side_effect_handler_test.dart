import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/services/stub_tailscale_admin_api.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/tailscale_acl_merge_side_effect_handler.dart';

import 'sync_test_harness.dart';

void main() {
  test('reconciles ACL when creator has admin key on HousemateJoined', () async {
    final harness = await SyncTestHarness.create(nodeKey: 'creator-node');
    const houseId = 'house-1';
    const creatorId = 'creator';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: creatorId,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: creatorId,
            houseId: houseId,
            tailscaleUserId: 'u1',
            tailscaleNodeKey: 'creator-node',
            nickname: 'Creator',
            memberStatus: MemberStatus.active.wireValue,
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: 'joiner',
            houseId: houseId,
            tailscaleUserId: 'u2',
            tailscaleNodeKey: 'joiner-node',
            nickname: 'Joiner',
            memberStatus: MemberStatus.active.wireValue,
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    await harness.localSettingsRepository.setTailscaleAdminApiKey(
      'tskey-api-test',
    );

    final tailscale = StubTailscaleAdminApi();
    final handler = TailscaleAclMergeSideEffectHandler(
      db: harness.db,
      localSettings: harness.localSettingsRepository,
      tailscaleAdminOverride: tailscale,
    );

    await handler.handle([
      HousemateJoined(
        houseId: houseId,
        memberId: 'joiner',
        tailscaleNodeKey: 'joiner-node',
        hlc: harness.hlcService.toBytes(harness.hlcService.now()),
      ),
    ]);

    expect(tailscale.reconciliations, hasLength(1));
    expect(tailscale.reconciliations.first.houseId, houseId);
    expect(tailscale.reconciliations.first.activeMembers, hasLength(2));
  });

  test('skips reconcile when not creator with admin key', () async {
    final harness = await SyncTestHarness.create(nodeKey: 'other-node');
    const houseId = 'house-2';
    const creatorId = 'creator';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: creatorId,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: creatorId,
            houseId: houseId,
            tailscaleUserId: 'u1',
            tailscaleNodeKey: 'creator-node',
            nickname: 'Creator',
            memberStatus: MemberStatus.active.wireValue,
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.localSettingsRepository.setTailscaleAdminApiKey(
      'tskey-api-test',
    );

    final tailscale = StubTailscaleAdminApi();
    final handler = TailscaleAclMergeSideEffectHandler(
      db: harness.db,
      localSettings: harness.localSettingsRepository,
      tailscaleAdminOverride: tailscale,
    );

    await handler.handle([
      HousemateJoined(
        houseId: houseId,
        memberId: 'joiner',
        tailscaleNodeKey: 'joiner-node',
        hlc: harness.hlcService.toBytes(harness.hlcService.now()),
      ),
    ]);

    expect(tailscale.reconciliations, isEmpty);
  });
}
