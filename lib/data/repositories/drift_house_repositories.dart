import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/repositories/house_repositories.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/merge_context.dart';
import 'package:rumah/sync/merge_engine.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/sync_envelope.dart';
import 'package:rumah/sync/sync_op_factory.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

import 'drift_ceremony_repository.dart';

class SyncWriteCoordinator {
  SyncWriteCoordinator({
    required AppDatabase db,
    required HlcService hlcService,
    required String deviceId,
    required MergeEngine mergeEngine,
    required MergeSideEffectHandler sideEffectHandler,
    Uuid? uuid,
  })  : _db = db,
        _hlcService = hlcService,
        _deviceId = deviceId,
        _mergeEngine = mergeEngine,
        _sideEffectHandler = sideEffectHandler,
        _opFactory = SyncOpFactory(hlcService: hlcService, deviceId: deviceId),
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final HlcService _hlcService;
  final String _deviceId;
  final MergeEngine _mergeEngine;
  final MergeSideEffectHandler _sideEffectHandler;
  final SyncOpFactory _opFactory;
  final Uuid _uuid;

  SyncOpFactory get opFactory => _opFactory;

  Future<MergeResult> emitLocalOps({
    required String houseId,
    required String tailscaleNodeKey,
    required String? senderMemberId,
    required List<SyncOperation> ops,
    String? joinCredential,
  }) async {
    final envelope = SyncEnvelope(
      protocolVersion: syncProtocolVersion,
      envelopeId: _uuid.v4(),
      houseId: houseId,
      senderDeviceId: _deviceId,
      senderTailscaleNodeKey: tailscaleNodeKey,
      senderMemberId: senderMemberId,
      hlc: base64Encode(_hlcService.toBytes(_hlcService.now())),
      ops: ops,
      joinCredential: joinCredential,
    );

    await _db.into(_db.syncOutboxEntries).insert(
          SyncOutboxEntriesCompanion.insert(
            opId: envelope.envelopeId,
            houseId: houseId,
            envelopeJson: jsonEncode(envelope.toJson()),
            createdAtMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    final context = await buildMergeContext(
      houseId,
      senderMemberId: senderMemberId,
    );
    final result = await _mergeEngine.applyOps(ops, context);
    await _sideEffectHandler.handle(result.sideEffects);
    return result;
  }

  Future<MergeResult> ingestEnvelope(SyncEnvelope envelope) async {
    final context = await buildMergeContext(
      envelope.houseId,
      senderMemberId: envelope.senderMemberId,
    );
    final result = await _mergeEngine.applyOps(envelope.ops, context);
    await _sideEffectHandler.handle(result.sideEffects);
    return result;
  }

  Future<MergeContext> buildMergeContext(
    String houseId, {
    String? senderMemberId,
  }) async {
    final housemates = await (_db.select(_db.housematesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final applied = await (_db.select(_db.syncAppliedOps)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    final activeKeys = housemates
        .where((m) => m.memberStatus == MemberStatus.active.wireValue)
        .map((m) => m.tailscaleNodeKey)
        .toSet();
    return MergeContext(
      houseId: houseId,
      activeMemberNodeKeys: activeKeys,
      localNodeKey: settings?.tailscaleNodeId ?? '',
      appliedOpIds: applied.map((a) => a.opId).toSet(),
      memberStatusById: {
        for (final m in housemates)
          m.memberId: MemberStatus.fromWire(m.memberStatus),
      },
      senderMemberId: senderMemberId,
    );
  }

  Future<int> pendingOpCount() async {
    final rows = await (_db.select(_db.syncOutboxEntries)
          ..where((t) => t.broadcasted.equals(false)))
        .get();
    return rows.length;
  }
}

class DriftHouseRepository implements HouseRepository {
  DriftHouseRepository({
    required AppDatabase db,
    required SyncWriteCoordinator sync,
    required JoinCredentialService joinCredentialService,
    Uuid? uuid,
  })  : _db = db,
        _sync = sync,
        _joinCredentialService = joinCredentialService,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncWriteCoordinator _sync;
  final JoinCredentialService _joinCredentialService;
  final Uuid _uuid;

  @override
  Future<House> createHouse({
    required String displayName,
    required String creatorMemberId,
  }) async {
    final houseId = _uuid.v4();
    final secret = _joinCredentialService.generateHouseSecret();
    await _db.into(_db.houseJoinSecrets).insert(
          HouseJoinSecretsCompanion.insert(
            houseId: houseId,
            secretBase64: secret,
          ),
        );
    final op = _sync.opFactory.houseCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      displayName: displayName,
      creatorMemberId: creatorMemberId,
    );
    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: null,
      ops: [op],
    );
    await (_db.update(_db.localUserSettings)
          ..where((t) => t.deviceId.equals(settings!.deviceId)))
        .write(LocalUserSettingsCompanion(activeHouseId: Value(houseId)));
    final row = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingle();
    return House(
      houseId: row.houseId,
      displayName: row.displayName,
      creatorMemberId: row.creatorMemberId,
      rulesVersion: row.rulesVersion,
      createdAtHlc: row.createdAtHlc,
      updatedAtHlc: row.updatedAtHlc,
    );
  }

  @override
  Future<String> generateJoinCredential(String houseId) async {
    final secretRow = await (_db.select(_db.houseJoinSecrets)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingle();
    final credential = _joinCredentialService.create(
      houseId: houseId,
      houseSecret: secretRow.secretBase64,
    );
    return credential.encode();
  }

  @override
  Future<JoinInvitePayload> buildInvite({
    required String houseId,
    required String hostNodeKey,
    required String hostMagicDns,
  }) async {
    final joinCredential = await generateJoinCredential(houseId);
    return JoinInvitePayload(
      payloadVersion: joinInvitePayloadVersion,
      houseId: houseId,
      hostNodeKey: hostNodeKey,
      hostMagicDns: hostMagicDns,
      joinCredential: joinCredential,
    );
  }
}

class DriftHousemateRepository implements HousemateRepository {
  DriftHousemateRepository({
    required AppDatabase db,
    required SyncWriteCoordinator sync,
    Uuid? uuid,
  })  : _db = db,
        _sync = sync,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncWriteCoordinator _sync;
  final Uuid _uuid;

  @override
  Future<Housemate> addCreatorHousemate({
    required String houseId,
    required String memberId,
    required String tailscaleUserId,
    required String tailscaleNodeKey,
    required String nickname,
  }) async {
    final createOp = _sync.opFactory.housemateCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      memberId: memberId,
      tailscaleUserId: tailscaleUserId,
      tailscaleNodeKey: tailscaleNodeKey,
      nickname: nickname,
      rotationOrderIndex: 0,
    );
    final rotationOp = _sync.opFactory.rotationAssignment(
      opId: _uuid.v4(),
      houseId: houseId,
      memberId: memberId,
      rotationOrderIndex: 0,
    );
    await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: tailscaleNodeKey,
      senderMemberId: memberId,
      ops: [createOp, rotationOp],
    );
    return _toEntity(await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle());
  }

  @override
  Future<Housemate> joinHousemate({
    required String houseId,
    required String memberId,
    required String tailscaleUserId,
    required String tailscaleNodeKey,
    required String nickname,
    required int rotationOrderIndex,
    String? joinCredential,
  }) async {
    final createOp = _sync.opFactory.housemateCreate(
      opId: _uuid.v4(),
      houseId: houseId,
      memberId: memberId,
      tailscaleUserId: tailscaleUserId,
      tailscaleNodeKey: tailscaleNodeKey,
      nickname: nickname,
    );
    final rotationOp = _sync.opFactory.rotationAssignment(
      opId: _uuid.v4(),
      houseId: houseId,
      memberId: memberId,
      rotationOrderIndex: rotationOrderIndex,
    );
    await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: tailscaleNodeKey,
      senderMemberId: memberId,
      ops: [createOp, rotationOp],
      joinCredential: joinCredential,
    );
    await bumpRulesVersionIfDrafting(
      db: _db,
      sync: _sync,
      houseId: houseId,
      senderMemberId: memberId,
      uuid: _uuid,
    );
    return _toEntity(await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingle());
  }

  @override
  Future<int> nextRotationIndex(String houseId) async {
    final rows = await (_db.select(_db.housematesSync)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final indices = rows
        .map((r) => r.rotationOrderIndex)
        .whereType<int>();
    if (indices.isEmpty) {
      return 0;
    }
    return indices.reduce((a, b) => a > b ? a : b) + 1;
  }

  Housemate _toEntity(HousematesSyncData row) => Housemate(
        memberId: row.memberId,
        houseId: row.houseId,
        tailscaleUserId: row.tailscaleUserId,
        tailscaleNodeKey: row.tailscaleNodeKey,
        nickname: row.nickname,
        lifetimeScore: row.lifetimeScore,
        rotationOrderIndex: row.rotationOrderIndex,
        memberStatus: MemberStatus.fromWire(row.memberStatus),
        evictedAtHlc: row.evictedAtHlc,
        updatedAtHlc: row.updatedAtHlc,
      );
}

class DriftAuditLogRepository implements AuditLogRepository {
  DriftAuditLogRepository({
    required AppDatabase db,
    required SyncWriteCoordinator sync,
    Uuid? uuid,
  })  : _db = db,
        _sync = sync,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncWriteCoordinator _sync;
  final Uuid _uuid;

  @override
  Future<AuditLogEntry> appendEntry({
    required String houseId,
    required String taskId,
    required String actorMemberId,
    required String action,
    String? justificationNotes,
  }) async {
    final logId = _uuid.v4();
    final settings = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    final op = _sync.opFactory.auditLogAppend(
      opId: _uuid.v4(),
      houseId: houseId,
      logId: logId,
      taskId: taskId,
      actorMemberId: actorMemberId,
      action: action,
      justificationNotes: justificationNotes,
    );
    await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: actorMemberId,
      ops: [op],
    );
    final row = await (_db.select(_db.auditLogAppendOnly)
          ..where((t) => t.logId.equals(logId)))
        .getSingle();
    return AuditLogEntry(
      logId: row.logId,
      houseId: row.houseId,
      taskId: row.taskId,
      actorMemberId: row.actorMemberId,
      action: row.action,
      justificationNotes: row.justificationNotes,
      hlc: row.hlc,
    );
  }
}
