import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/privilege_tier_ids.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('score crossing threshold emits privilege_tier_crossing audit', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const memberId = 'member-1';
    const eventId = 'score-event-1';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberId,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);

    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: eventId,
        memberId: memberId,
        delta: 80,
      ),
      houseId,
    );

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.action.equals('privilege_tier_crossing')))
        .get();
    expect(audits, isNotEmpty);

    final parkingAudit = audits.firstWhere(
      (a) => a.taskId == crossingTaskId('parking'),
    );
    expect(parkingAudit.actorMemberId, memberId);
    final payload = jsonDecode(parkingAudit.justificationNotes!) as Map;
    expect(payload['direction'], 'unlocked');
    expect(payload['template_id'], 'parking');
    expect(payload['triggering_event_id'], eventId);
    expect(
      parkingAudit.logId,
      crossingLogId(
        houseId: houseId,
        memberId: memberId,
        templateId: 'parking',
        direction: 'unlocked',
        triggeringEventId: eventId,
      ),
    );
  });

  test('same score event on replay produces no duplicate audit', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const memberId = 'member-1';
    const eventId = 'score-event-dup';
    final opId = uuid.v4();

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberId,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);

    final op = harness.scoreEvent(
      opId: opId,
      houseId: houseId,
      eventId: eventId,
      memberId: memberId,
      delta: 80,
    );
    await harness.apply(op, houseId);
    await harness.apply(op, houseId);

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.action.equals('privilege_tier_crossing')))
        .get();
    final parkingAudits =
        audits.where((a) => a.taskId == crossingTaskId('parking')).toList();
    expect(parkingAudits.length, 1);
  });

  test('non-crossing score change emits no privilege audit', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    const memberId = 'member-1';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: memberId,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedHousemate(houseId: houseId, memberId: memberId);

    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: 'evt-1',
        memberId: memberId,
        delta: 10,
      ),
      houseId,
    );
    await harness.apply(
      harness.scoreEvent(
        opId: uuid.v4(),
        houseId: houseId,
        eventId: 'evt-2',
        memberId: memberId,
        delta: 5,
      ),
      houseId,
    );

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.action.equals('privilege_tier_crossing')))
        .get();
    expect(audits, isEmpty);
  });

  test('task reject does not change score in slice 1', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final taskId = uuid.v4();
    final cycleId = uuid.v4();
    const guardian = 'guardian';
    const claimer = 'claimer';

    await harness.db.into(harness.db.houseSync).insert(
          HouseSyncCompanion.insert(
            houseId: houseId,
            displayName: 'Home',
            creatorMemberId: guardian,
            createdAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
            updatedAtHlc: harness.hlcService.toBytes(harness.hlcService.now()),
          ),
        );
    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: guardian,
    );
    await harness.seedHousemate(houseId: houseId, memberId: guardian);
    await harness.seedHousemate(houseId: houseId, memberId: claimer);
    await harness.seedTask(
      houseId: houseId,
      taskId: taskId,
      cycleId: cycleId,
      status: TaskStatus.pendingReview.wireValue,
      points: 10,
      claimedByMemberIds: [claimer],
    );

    final memberBefore = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(claimer)))
        .getSingle();

    await harness.apply(
      harness.taskStatusUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        taskId: taskId,
        actorMemberId: guardian,
        from: TaskStatus.pendingReview,
        to: TaskStatus.open,
      ),
      houseId,
    );

    final memberAfter = await (harness.db.select(harness.db.housematesSync)
          ..where((t) => t.memberId.equals(claimer)))
        .getSingle();
    expect(memberAfter.lifetimeScore, memberBefore.lifetimeScore);

    final audits = await (harness.db.select(harness.db.auditLogAppendOnly)
          ..where((t) => t.action.equals('privilege_tier_crossing')))
        .get();
    expect(audits, isEmpty);
  });
}
