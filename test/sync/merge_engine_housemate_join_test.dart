import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/sync_operation.dart';

import 'sync_test_harness.dart';

void main() {
  test('housemateCreate emits HousemateJoined side effect', () async {
    final harness = await SyncTestHarness.create();
    final house = await harness.houseRepository.createHouse(
      displayName: 'Join House',
      creatorMemberId: 'creator',
    );

    final op = SyncOperation(
      opId: 'op-join-1',
      opType: SyncOpType.housemateCreate.wireValue,
      houseId: house.houseId,
      originDeviceId: harness.deviceId,
      hlc: base64Encode(harness.hlcService.toBytes(harness.hlcService.now())),
      payload: {
        'member_id': 'mate-1',
        'tailscale_user_id': 'user-1',
        'tailscale_node_key': 'node-1',
        'nickname': 'Mate',
        'member_status': 'active',
      },
    );

    final ctx = await harness.contextFor(house.houseId);
    final result = await harness.mergeEngine.applyOps([op], ctx);

    expect(result.appliedOpIds, ['op-join-1']);
    expect(
      result.sideEffects.whereType<HousemateJoined>(),
      hasLength(1),
    );
    final joined = result.sideEffects.whereType<HousemateJoined>().first;
    expect(joined.memberId, 'mate-1');
    expect(joined.tailscaleNodeKey, 'node-1');
    expect(joined.houseId, house.houseId);
  });
}
