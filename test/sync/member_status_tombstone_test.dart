import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/merge_context.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('evicted sender rejected at ingress', () {
    final context = MergeContext(
      houseId: 'house-1',
      activeMemberNodeKeys: {'node-a'},
      localNodeKey: 'node-a',
      appliedOpIds: {},
      memberStatusById: {'member-1': MemberStatus.evicted},
    );

    final result = context.checkTombstone(
      senderMemberId: 'member-1',
      actorMemberId: 'member-1',
      opType: SyncOpType.housemateNicknameUpdate.wireValue,
    );
    expect(result.allowed, isFalse);
  });

  test('evicted actor ops rejected except execution transitions', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberId = uuid.v4();

    await harness.db.into(harness.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: memberId,
            houseId: houseId,
            tailscaleUserId: 'user',
            tailscaleNodeKey: harness.nodeKey,
            nickname: 'Soon evicted',
            memberStatus: MemberStatus.evicted.wireValue,
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );

    final blocked = await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: uuid.v4(),
        memberId: memberId,
        delta: 5,
      ),
      houseId,
    );
    expect(blocked.rejectedOpIds.length, 1);

    final allowed = await harness.apply(
      harness.memberStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        memberId: memberId,
        from: MemberStatus.evicted,
        to: MemberStatus.evicted,
      ),
      houseId,
    );
    expect(allowed.rejectedOpIds.length, 1);
  });
}
