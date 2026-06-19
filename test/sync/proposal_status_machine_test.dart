import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('valid transitions apply', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final proposalId = uuid.v4();

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: uuid.v4(),
        type: ProposalType.eviction,
      ),
      houseId,
    );

    final result = await harness.apply(
      harness.proposalStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        from: ProposalStatus.proposed,
        to: ProposalStatus.approved,
      ),
      houseId,
    );
    expect(result.appliedOpIds.length, 1);
  });

  test('invalid transitions rejected', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final proposalId = uuid.v4();

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: uuid.v4(),
      ),
      houseId,
    );

    final result = await harness.apply(
      harness.proposalStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        from: ProposalStatus.proposed,
        to: ProposalStatus.executed,
      ),
      houseId,
    );
    expect(result.rejectedOpIds.length, 1);
  });

  test('terminal states locked', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final proposalId = uuid.v4();

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: uuid.v4(),
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
    await harness.apply(
      harness.proposalStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        from: ProposalStatus.readyToExecute,
        to: ProposalStatus.executed,
      ),
      houseId,
    );

    final blocked = await harness.apply(
      harness.proposalStatusTransition(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        from: ProposalStatus.executed,
        to: ProposalStatus.proposed,
      ),
      houseId,
    );
    expect(blocked.rejectedOpIds.length, 1);
  });
}
