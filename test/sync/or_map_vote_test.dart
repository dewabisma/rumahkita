import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'sync_test_harness.dart';

void main() {
  test('latest HLC wins for same voter key', () async {
    final harness = await SyncTestHarness.create();
    const uuid = Uuid();
    final houseId = uuid.v4();
    final proposalId = uuid.v4();
    final voterId = uuid.v4();

    await harness.apply(
      harness.proposalCreate(
        opId: uuid.v4(),
        houseId: houseId,
        proposalId: proposalId,
        targetMemberId: uuid.v4(),
      ),
      houseId,
    );

    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: uuid.v4(),
        proposalId: proposalId,
        voterMemberId: voterId,
        voteCast: true,
      ),
      houseId,
    );

    await Future<void>.delayed(const Duration(milliseconds: 2));

    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: uuid.v4(),
        proposalId: proposalId,
        voterMemberId: voterId,
        voteCast: false,
      ),
      houseId,
    );

    final votes = await (harness.db.select(harness.db.proposalVotesSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .get();
    expect(votes.length, 1);
    expect(votes.single.voteCast, 0);
  });

  test('different voters remain independent', () async {
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

    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: uuid.v4(),
        proposalId: proposalId,
        voterMemberId: uuid.v4(),
        voteCast: true,
      ),
      houseId,
    );
    await harness.apply(
      harness.voteCast(
        opId: uuid.v4(),
        houseId: houseId,
        voteId: uuid.v4(),
        proposalId: proposalId,
        voterMemberId: uuid.v4(),
        voteCast: false,
      ),
      houseId,
    );

    final votes = await (harness.db.select(harness.db.proposalVotesSync)
          ..where((t) => t.proposalId.equals(proposalId)))
        .get();
    expect(votes.length, 2);
  });
}
