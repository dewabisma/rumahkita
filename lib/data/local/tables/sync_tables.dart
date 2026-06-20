import 'package:drift/drift.dart';

class LocalUserSettings extends Table {
  TextColumn get deviceId => text()();
  TextColumn get tailscaleNodeId => text().withDefault(const Constant(''))();
  TextColumn get activeHouseId => text().nullable()();
  BlobColumn get createdAtHlc => blob()();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

class HouseSync extends Table {
  TextColumn get houseId => text()();
  TextColumn get displayName => text()();
  TextColumn get creatorMemberId => text()();
  IntColumn get rulesVersion => integer().withDefault(const Constant(0))();
  BlobColumn get createdAtHlc => blob()();
  BlobColumn get updatedAtHlc => blob()();
  BlobColumn get displayNameHlc => blob().nullable()();
  TextColumn get displayNameDeviceId => text().nullable()();
  BlobColumn get rulesVersionHlc => blob().nullable()();
  TextColumn get rulesVersionDeviceId => text().nullable()();
  TextColumn get privilegeTemplates =>
      text().withDefault(const Constant('{}'))();
  BlobColumn get privilegeTemplatesHlc => blob().nullable()();
  TextColumn get privilegeTemplatesDeviceId => text().nullable()();
  IntColumn get cycleDurationDays => integer().withDefault(const Constant(7))();
  BlobColumn get cycleDurationDaysHlc => blob().nullable()();
  TextColumn get cycleDurationDaysDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {houseId};
}

class HousematesSync extends Table {
  TextColumn get memberId => text()();
  TextColumn get houseId => text()();
  TextColumn get tailscaleUserId => text()();
  TextColumn get tailscaleNodeKey => text().unique()();
  TextColumn get nickname => text()();
  IntColumn get lifetimeScore => integer().withDefault(const Constant(0))();
  IntColumn get rotationOrderIndex => integer().nullable()();
  TextColumn get memberStatus => text()();
  BlobColumn get evictedAtHlc => blob().nullable()();
  BlobColumn get updatedAtHlc => blob()();
  BlobColumn get nicknameHlc => blob().nullable()();
  TextColumn get nicknameDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {memberId};
}

class ScoreEvents extends Table {
  TextColumn get eventId => text()();
  TextColumn get houseId => text()();
  TextColumn get memberId => text()();
  IntColumn get delta => integer()();
  TextColumn get reasonRef => text().nullable()();
  BlobColumn get hlc => blob()();
  TextColumn get actorDeviceId => text()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

class RemovalProposalsSync extends Table {
  TextColumn get proposalId => text()();
  TextColumn get houseId => text()();
  TextColumn get targetMemberId => text()();
  TextColumn get proposerMemberId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  BlobColumn get createdAtHlc => blob()();
  BlobColumn get updatedAtHlc => blob()();
  BlobColumn get statusHlc => blob().nullable()();
  TextColumn get statusDeviceId => text().nullable()();
  BlobColumn get votingWindowEndsAtHlc => blob().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {proposalId};
}

class ProposalVotesSync extends Table {
  TextColumn get voteId => text()();
  TextColumn get houseId => text()();
  TextColumn get proposalId => text()();
  TextColumn get voterMemberId => text()();
  IntColumn get voteCast => integer()();
  BlobColumn get hlc => blob()();
  TextColumn get originDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {voteId};
}

class CyclesSync extends Table {
  TextColumn get cycleId => text()();
  TextColumn get houseId => text()();
  TextColumn get activeGuardianMemberId => text()();
  TextColumn get status => text()();
  TextColumn get ceremonySignoffs => text().withDefault(const Constant('{}'))();
  IntColumn get rulesVersionAtSignoff => integer().withDefault(const Constant(0))();
  BlobColumn get updatedAtHlc => blob()();
  BlobColumn get statusHlc => blob().nullable()();
  TextColumn get statusDeviceId => text().nullable()();
  BlobColumn get guardianHlc => blob().nullable()();
  TextColumn get guardianDeviceId => text().nullable()();
  BlobColumn get rulesVersionAtSignoffHlc => blob().nullable()();
  TextColumn get rulesVersionAtSignoffDeviceId => text().nullable()();
  BlobColumn get startedAtHlc => blob().nullable()();
  BlobColumn get endsAtHlc => blob().nullable()();
  TextColumn get cycleStartScoresJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get handoverStep => text().nullable()();
  BlobColumn get handoverStepHlc => blob().nullable()();
  TextColumn get handoverStepDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {cycleId};
}

class TasksSync extends Table {
  TextColumn get taskId => text()();
  TextColumn get houseId => text()();
  TextColumn get cycleId => text()();
  TextColumn get title => text()();
  IntColumn get negotiatedPoints => integer()();
  TextColumn get status => text()();
  TextColumn get claimedByMemberIds =>
      text().withDefault(const Constant('[]'))();
  BlobColumn get updatedAtHlc => blob()();
  BlobColumn get titleHlc => blob().nullable()();
  TextColumn get titleDeviceId => text().nullable()();
  BlobColumn get pointsHlc => blob().nullable()();
  TextColumn get pointsDeviceId => text().nullable()();
  BlobColumn get statusHlc => blob().nullable()();
  TextColumn get statusDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {taskId};
}

class TaskClaimEvents extends Table {
  TextColumn get eventId => text()();
  TextColumn get houseId => text()();
  TextColumn get taskId => text()();
  TextColumn get memberId => text()();
  BlobColumn get hlc => blob()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

class AuditLogAppendOnly extends Table {
  TextColumn get logId => text()();
  TextColumn get houseId => text()();
  TextColumn get taskId => text()();
  TextColumn get actorMemberId => text()();
  TextColumn get action => text()();
  TextColumn get justificationNotes => text().nullable()();
  BlobColumn get hlc => blob()();

  @override
  Set<Column<Object>> get primaryKey => {logId};
}

class SyncOutboxEntries extends Table {
  TextColumn get opId => text()();
  TextColumn get houseId => text()();
  TextColumn get envelopeJson => text()();
  IntColumn get createdAtMs => integer()();
  BoolColumn get broadcasted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {opId};
}

class SyncAppliedOps extends Table {
  TextColumn get opId => text()();
  TextColumn get houseId => text()();
  BlobColumn get appliedAtHlc => blob()();

  @override
  Set<Column<Object>> get primaryKey => {opId};
}

class SyncPeerState extends Table {
  TextColumn get peerNodeKey => text()();
  TextColumn get houseId => text()();
  TextColumn get lastEnvelopeId => text().nullable()();
  BlobColumn get lastSeenHlc => blob().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {peerNodeKey, houseId};
}

class SyncPeerAllowlist extends Table {
  TextColumn get tailscaleNodeKey => text()();
  TextColumn get houseId => text()();
  TextColumn get memberId => text().nullable()();
  BoolColumn get isLocalDevice => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {tailscaleNodeKey, houseId};
}

class ConsumedJoinCredentials extends Table {
  TextColumn get nonce => text()();
  TextColumn get houseId => text()();
  TextColumn get consumedByNodeKey => text()();
  IntColumn get consumedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {nonce};
}

class HouseJoinSecrets extends Table {
  TextColumn get houseId => text()();
  TextColumn get secretBase64 => text()();

  @override
  Set<Column<Object>> get primaryKey => {houseId};
}
