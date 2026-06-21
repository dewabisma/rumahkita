import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/privilege_status.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('privilege create only allowed during drafting', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: 'guardian',
      status: 'active',
    );

    final rejected = await harness.apply(
      harness.privilegeCreate(
        opId: uuid.v4(),
        houseId: houseId,
        privilegeId: privilegeId,
        cycleId: cycleId,
      ),
      houseId,
    );
    expect(rejected.rejectedOpIds.length, 1);

    await (harness.db.update(harness.db.cyclesSync)
          ..where((t) => t.cycleId.equals(cycleId)))
        .write(const CyclesSyncCompanion(status: Value('drafting')));

    final accepted = await harness.apply(
      harness.privilegeCreate(
        opId: uuid.v4(),
        houseId: houseId,
        privilegeId: privilegeId,
        cycleId: cycleId,
      ),
      houseId,
    );
    expect(accepted.appliedOpIds.length, 1);

    final row = await (harness.db.select(harness.db.privilegesSync)
          ..where((t) => t.privilegeId.equals(privilegeId)))
        .getSingle();
    expect(row.name, 'New perk');
    expect(row.pointCost, 15);
  });

  test('archive privilege via field update', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final cycleId = uuid.v4();
    final privilegeId = uuid.v4();

    await harness.seedCycle(
      houseId: houseId,
      cycleId: cycleId,
      guardianMemberId: 'guardian',
      status: 'drafting',
    );
    await harness.seedPrivilege(
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
    );

    final result = await harness.apply(
      harness.opFactory.privilegeFieldUpdate(
        opId: uuid.v4(),
        houseId: houseId,
        privilegeId: privilegeId,
        field: 'status',
        value: PrivilegeStatus.archived.wireValue,
      ),
      houseId,
    );
    expect(result.appliedOpIds.length, 1);

    final row = await (harness.db.select(harness.db.privilegesSync)
          ..where((t) => t.privilegeId.equals(privilegeId)))
        .getSingle();
    expect(row.status, PrivilegeStatus.archived.wireValue);
  });
}
