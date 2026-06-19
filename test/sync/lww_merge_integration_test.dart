import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('lower HLC nickname write is rejected after higher HLC write', () async {
    final peerA = await SyncTestHarness.create(deviceId: 'device-a', nodeKey: 'node-a');
    final peerB = await SyncTestHarness.create(deviceId: 'device-b', nodeKey: 'node-b');
    const uuid = Uuid();
    final houseId = uuid.v4();
    final memberId = uuid.v4();

    await peerA.db.into(peerA.db.housematesSync).insert(
          HousematesSyncCompanion.insert(
            memberId: memberId,
            houseId: houseId,
            tailscaleUserId: 'user-a',
            tailscaleNodeKey: peerA.nodeKey,
            nickname: 'Original',
            memberStatus: 'active',
            updatedAtHlc: peerA.hlcService.toBytes(peerA.hlcService.now()),
          ),
        );

    final highHlc = peerA.hlcService.now();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final highOp = SyncOperation(
      opId: uuid.v4(),
      opType: SyncOpType.housemateNicknameUpdate.wireValue,
      houseId: houseId,
      originDeviceId: peerA.deviceId,
      hlc: base64Encode(peerA.hlcService.toBytes(highHlc)),
      actorMemberId: memberId,
      payload: {'member_id': memberId, 'nickname': 'Winner'},
    );
    await peerA.apply(highOp, houseId);

    final lowHlc = HybridLogicalClock(l: highHlc.l - 1, c: 0);
    final lowOp = SyncOperation(
      opId: uuid.v4(),
      opType: SyncOpType.housemateNicknameUpdate.wireValue,
      houseId: houseId,
      originDeviceId: peerB.deviceId,
      hlc: base64Encode(lowHlc.toUint8List()),
      actorMemberId: memberId,
      payload: {'member_id': memberId, 'nickname': 'Loser'},
    );
    final result = await peerB.apply(lowOp, houseId);
    expect(result.rejectedOpIds.length, 1);

    final member = await (peerA.db.select(peerA.db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle();
    expect(member.nickname, 'Winner');
    expect(member.nicknameDeviceId, peerA.deviceId);
  });
}
