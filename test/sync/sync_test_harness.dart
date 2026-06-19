import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/sync/ceremony_merge_side_effect_handler.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/merge_context.dart';
import 'package:rumah/sync/merge_engine.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/sync_op_factory.dart';
import 'package:rumah/sync/sync_operation.dart';

class SyncTestHarness {
  SyncTestHarness({
    required this.db,
    required this.deviceId,
    required this.nodeKey,
    required this.hlcService,
    required this.mergeEngine,
    required this.syncCoordinator,
    required this.opFactory,
    required this.houseRepository,
    required this.housemateRepository,
    required this.auditLogRepository,
    required this.joinCredentialService,
    required this.sideEffectHandler,
  });

  final AppDatabase db;
  final String deviceId;
  final String nodeKey;
  final HlcService hlcService;
  final MergeEngine mergeEngine;
  final SyncWriteCoordinator syncCoordinator;
  final SyncOpFactory opFactory;
  final DriftHouseRepository houseRepository;
  final DriftHousemateRepository housemateRepository;
  final DriftAuditLogRepository auditLogRepository;
  final JoinCredentialService joinCredentialService;
  final CeremonyMergeSideEffectHandler sideEffectHandler;

  static Future<SyncTestHarness> create({
    String deviceId = 'device-a',
    String nodeKey = 'node-a',
  }) async {
    final db = openMemoryDatabase();
    final hlcService = HlcService(deviceId: deviceId);
    await db.into(db.localUserSettings).insert(
          LocalUserSettingsCompanion.insert(
            deviceId: deviceId,
            tailscaleNodeId: Value(nodeKey),
            createdAtHlc: hlcService.toBytes(hlcService.now()),
          ),
        );
    final mergeEngine = MergeEngine(db);
    final sideEffectHandler = CeremonyMergeSideEffectHandler(db);
    final syncCoordinator = SyncWriteCoordinator(
      db: db,
      hlcService: hlcService,
      deviceId: deviceId,
      mergeEngine: mergeEngine,
      sideEffectHandler: sideEffectHandler,
    );
    final joinCredentialService = JoinCredentialService();
    final houseRepository = DriftHouseRepository(
      db: db,
      sync: syncCoordinator,
      joinCredentialService: joinCredentialService,
    );
    return SyncTestHarness(
      db: db,
      deviceId: deviceId,
      nodeKey: nodeKey,
      hlcService: hlcService,
      mergeEngine: mergeEngine,
      syncCoordinator: syncCoordinator,
      opFactory: SyncOpFactory(hlcService: hlcService, deviceId: deviceId),
      houseRepository: houseRepository,
      housemateRepository: DriftHousemateRepository(
        db: db,
        sync: syncCoordinator,
      ),
      auditLogRepository: DriftAuditLogRepository(
        db: db,
        sync: syncCoordinator,
      ),
      joinCredentialService: joinCredentialService,
      sideEffectHandler: sideEffectHandler,
    );
  }

  Future<MergeContext> contextFor(String houseId) =>
      syncCoordinator.buildMergeContext(houseId);

  Future<MergeResult> apply(SyncOperation op, String houseId) async {
    final ctx = await contextFor(houseId);
    final result = await mergeEngine.applyOps([op], ctx);
    await sideEffectHandler.handle(result.sideEffects);
    return result;
  }

  SyncOperation proposalStatusTransition({
    required String opId,
    required String houseId,
    required String proposalId,
    ProposalStatus? from,
    required ProposalStatus to,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.proposalStatusTransition.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'proposal_id': proposalId,
        if (from != null) 'from': from.wireValue,
        'to': to.wireValue,
      },
    );
  }

  SyncOperation memberStatusTransition({
    required String opId,
    required String houseId,
    required String memberId,
    MemberStatus? from,
    required MemberStatus to,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.memberStatusTransition.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'member_id': memberId,
        if (from != null) 'from': from.wireValue,
        'to': to.wireValue,
      },
    );
  }

  SyncOperation proposalCreate({
    required String opId,
    required String houseId,
    required String proposalId,
    required String targetMemberId,
    ProposalType type = ProposalType.eviction,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.proposalCreate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'proposal_id': proposalId,
        'target_member_id': targetMemberId,
        'type': type.wireValue,
        'status': ProposalStatus.proposed.wireValue,
      },
    );
  }

  SyncOperation voteCast({
    required String opId,
    required String houseId,
    required String voteId,
    required String proposalId,
    required String voterMemberId,
    required bool voteCast,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.voteCast.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: voterMemberId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'vote_id': voteId,
        'proposal_id': proposalId,
        'voter_member_id': voterMemberId,
        'vote_cast': voteCast,
      },
    );
  }

  SyncOperation scoreEvent({
    required String opId,
    required String houseId,
    required String eventId,
    required String memberId,
    required int delta,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.scoreEventAppend.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: memberId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'event_id': eventId,
        'member_id': memberId,
        'delta': delta,
      },
    );
  }

  SyncOperation taskClaim({
    required String opId,
    required String houseId,
    required String eventId,
    required String taskId,
    required String memberId,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.taskClaim.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'event_id': eventId,
        'task_id': taskId,
        'member_id': memberId,
      },
    );
  }

  SyncOperation cycleStatusTransition({
    required String opId,
    required String houseId,
    required String cycleId,
    String? from,
    required String to,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.cycleStatusTransition.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'cycle_id': cycleId,
        if (from != null) 'from': from,
        'to': to,
      },
    );
  }
}
