import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/data/repositories/secure_key_value_store.dart';
import 'package:rumah/data/repositories/drift_removal_repository.dart';
import 'package:rumah/domain/repositories/removal_repository.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/enums/proposal_status.dart';
import 'package:rumah/domain/enums/proposal_type.dart';
import 'package:rumah/domain/enums/sync_op_type.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/services/stub_tailscale_admin_api.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/removal_execution_watcher.dart';
import 'package:rumah/sync/ceremony_merge_side_effect_handler.dart';
import 'package:rumah/sync/handover_merge_side_effect_handler.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/merge_context.dart';
import 'package:rumah/sync/merge_engine.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/privilege_cycle_merge_side_effect_handler.dart';
import 'package:rumah/sync/privilege_redeem_merge_side_effect_handler.dart';
import 'package:rumah/sync/removal_merge_side_effect_handler.dart';
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
  required this.handoverSideEffectHandler,
  required this.privilegeCycleSideEffectHandler,
  required this.privilegeRedeemSideEffectHandler,
  required this.removalSideEffectHandler,
  required this.removalRepository,
  required this.localSettingsRepository,
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
  final MergeSideEffectHandler sideEffectHandler;
  final HandoverMergeSideEffectHandler handoverSideEffectHandler;
  final PrivilegeCycleMergeSideEffectHandler privilegeCycleSideEffectHandler;
  final PrivilegeRedeemMergeSideEffectHandler privilegeRedeemSideEffectHandler;
  final RemovalMergeSideEffectHandler removalSideEffectHandler;
  final RemovalRepository removalRepository;
  final DriftLocalSettingsRepository localSettingsRepository;

  static Future<SyncTestHarness> create({
    String deviceId = 'device-a',
    String nodeKey = 'node-a',
  }) async {
    final db = openMemoryDatabase();
    final hlcService = HlcService(deviceId: deviceId);
    await db
        .into(db.localUserSettings)
        .insert(
          LocalUserSettingsCompanion.insert(
            deviceId: deviceId,
            tailscaleNodeId: Value(nodeKey),
            createdAtHlc: hlcService.toBytes(hlcService.now()),
          ),
        );
    final mergeEngine = MergeEngine(db);
    final ceremonySideEffectHandler = CeremonyMergeSideEffectHandler(db);
    final handoverSideEffectHandler = HandoverMergeSideEffectHandler(db);
    final privilegeCycleSideEffectHandler =
        PrivilegeCycleMergeSideEffectHandler(db);
    final privilegeRedeemSideEffectHandler =
        PrivilegeRedeemMergeSideEffectHandler(db);
    final removalSideEffectHandler = RemovalMergeSideEffectHandler(db);
    final sideEffectHandler = CompositeMergeSideEffectHandler([
      ceremonySideEffectHandler,
      handoverSideEffectHandler,
      privilegeCycleSideEffectHandler,
      privilegeRedeemSideEffectHandler,
      removalSideEffectHandler,
    ]);
    final syncCoordinator = SyncWriteCoordinator(
      db: db,
      hlcService: hlcService,
      deviceId: deviceId,
      mergeEngine: mergeEngine,
      sideEffectHandler: sideEffectHandler,
    );
    ceremonySideEffectHandler.bindSync(syncCoordinator);
    privilegeCycleSideEffectHandler.bindSync(syncCoordinator);
    privilegeRedeemSideEffectHandler.bindSync(syncCoordinator);
    removalSideEffectHandler.bindSync(syncCoordinator);
    final joinCredentialService = JoinCredentialService();
    final houseRepository = DriftHouseRepository(
      db: db,
      sync: syncCoordinator,
      joinCredentialService: joinCredentialService,
    );
    final housemateRepository = DriftHousemateRepository(
      db: db,
      sync: syncCoordinator,
    );
    final auditLogRepository = DriftAuditLogRepository(
      db: db,
      sync: syncCoordinator,
    );
    final localSettingsRepository = DriftLocalSettingsRepository(
      db: db,
      secureStorage: InMemorySecureKeyValueStore(),
    );
    final removalRepository = DriftRemovalRepository(
      db: db,
      sync: syncCoordinator,
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
      housemateRepository: housemateRepository,
      auditLogRepository: auditLogRepository,
      joinCredentialService: joinCredentialService,
      sideEffectHandler: sideEffectHandler,
      handoverSideEffectHandler: handoverSideEffectHandler,
      privilegeCycleSideEffectHandler: privilegeCycleSideEffectHandler,
      privilegeRedeemSideEffectHandler: privilegeRedeemSideEffectHandler,
      removalSideEffectHandler: removalSideEffectHandler,
      removalRepository: removalRepository,
      localSettingsRepository: localSettingsRepository,
    );
  }

  Future<void> setActiveHouse(String houseId) =>
      localSettingsRepository.setActiveHouseId(houseId);

  Future<ProviderContainer> watcherContainer({
    required String houseId,
    StubTailscaleAdminApi? tailscaleAdmin,
  }) async {
    await setActiveHouse(houseId);
    final tailscale = tailscaleAdmin ?? StubTailscaleAdminApi();
    final appState = AppState(
      db: db,
      deviceIdentity: DeviceIdentityService(),
      hlcService: hlcService,
      houseRepository: houseRepository,
      housemateRepository: housemateRepository,
      auditLogRepository: auditLogRepository,
      ceremonyRepository: DriftCeremonyRepository(
        db: db,
        sync: syncCoordinator,
      ),
      taskRepository: DriftTaskRepository(db: db, sync: syncCoordinator),
      removalRepository: removalRepository,
      syncWriteCoordinator: syncCoordinator,
      localSettingsRepository: localSettingsRepository,
      syncService: SyncService(
        db: db,
        syncWriteCoordinator: syncCoordinator,
        meshService: TailscaleMeshService(stateDirectory: '/tmp/rumah-test'),
        transport: TailscaleSyncTransport(),
        joinCredentialService: joinCredentialService,
        localSettings: localSettingsRepository,
      ),
      meshService: TailscaleMeshService(stateDirectory: '/tmp/rumah-test'),
      joinCredentialService: joinCredentialService,
      tailscaleAdminApi: tailscale,
    );
    return ProviderContainer(
      overrides: [
        appStateProvider.overrideWithValue(appState),
        tailscaleAdminApiProvider.overrideWithValue(tailscale),
      ],
    );
  }

  Future<MergeContext> contextFor(String houseId) =>
      syncCoordinator.buildMergeContext(houseId);

  Future<MergeResult> apply(SyncOperation op, String houseId) async {
    return applyBatch([op], houseId);
  }

  Future<MergeResult> applyBatch(
    List<SyncOperation> ops,
    String houseId,
  ) async {
    final ctx = await contextFor(houseId);
    final result = await mergeEngine.applyOps(ops, ctx);
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
    String? proposerMemberId,
    ProposalType type = ProposalType.eviction,
    String? justificationNotes,
  }) {
    return SyncOperation(
      opId: opId,
      opType: SyncOpType.proposalCreate.wireValue,
      houseId: houseId,
      originDeviceId: deviceId,
      actorMemberId: proposerMemberId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {
        'proposal_id': proposalId,
        'target_member_id': targetMemberId,
        if (proposerMemberId != null) 'proposer_member_id': proposerMemberId,
        'type': type.wireValue,
        'status': ProposalStatus.proposed.wireValue,
        if (justificationNotes != null) 'justification_notes': justificationNotes,
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
    String? reasonRef,
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
        if (reasonRef != null) 'reason_ref': reasonRef,
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
      actorMemberId: memberId,
      hlc: base64Encode(hlcService.toBytes(hlcService.now())),
      payload: {'event_id': eventId, 'task_id': taskId, 'member_id': memberId},
    );
  }

  SyncOperation taskStatusUpdate({
    required String opId,
    required String houseId,
    required String taskId,
    required String actorMemberId,
    required TaskStatus from,
    required TaskStatus to,
  }) {
    return opFactory.taskStatusUpdate(
      opId: opId,
      houseId: houseId,
      taskId: taskId,
      actorMemberId: actorMemberId,
      from: from,
      to: to,
    );
  }

  SyncOperation auditLogAppend({
    required String opId,
    required String houseId,
    required String logId,
    required String taskId,
    required String actorMemberId,
    required String action,
    String? justificationNotes,
  }) {
    return opFactory.auditLogAppend(
      opId: opId,
      houseId: houseId,
      logId: logId,
      taskId: taskId,
      actorMemberId: actorMemberId,
      action: action,
      justificationNotes: justificationNotes,
    );
  }

  Future<void> seedTask({
    required String houseId,
    required String taskId,
    required String cycleId,
    String status = 'open',
    int points = 10,
    List<String>? claimedByMemberIds,
  }) async {
    await db
        .into(db.tasksSync)
        .insert(
          TasksSyncCompanion.insert(
            taskId: taskId,
            houseId: houseId,
            cycleId: cycleId,
            title: 'Test chore',
            negotiatedPoints: points,
            status: status,
            claimedByMemberIds: Value(
              claimedByMemberIds != null
                  ? jsonEncode(claimedByMemberIds)
                  : '[]',
            ),
            updatedAtHlc: hlcService.toBytes(hlcService.now()),
          ),
        );
  }

  Future<void> seedCycle({
    required String houseId,
    required String cycleId,
    required String guardianMemberId,
    String status = 'active',
  }) async {
    await db
        .into(db.cyclesSync)
        .insert(
          CyclesSyncCompanion.insert(
            cycleId: cycleId,
            houseId: houseId,
            activeGuardianMemberId: guardianMemberId,
            status: status,
            updatedAtHlc: hlcService.toBytes(hlcService.now()),
          ),
        );
  }

  Future<void> seedPrivilege({
    required String houseId,
    required String privilegeId,
    required String cycleId,
    String status = 'active',
    int pointCost = 20,
    String name = 'Test perk',
    String usageMode = 'durable',
  }) async {
    await db.into(db.privilegesSync).insert(
          PrivilegesSyncCompanion.insert(
            privilegeId: privilegeId,
            houseId: houseId,
            cycleId: cycleId,
            name: name,
            description: 'A test perk',
            pointCost: pointCost,
            status: status,
            usageMode: usageMode,
            updatedAtHlc: hlcService.toBytes(hlcService.now()),
          ),
        );
  }

  SyncOperation privilegeCreate({
    required String opId,
    required String houseId,
    required String privilegeId,
    required String cycleId,
    String name = 'New perk',
    int pointCost = 15,
  }) {
    return opFactory.privilegeCreate(
      opId: opId,
      houseId: houseId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      name: name,
      description: 'Description',
      pointCost: pointCost,
    );
  }

  SyncOperation privilegeRedemptionCreate({
    required String opId,
    required String houseId,
    required String redemptionId,
    required String memberId,
    required String privilegeId,
    required String cycleId,
    required int pointCost,
  }) {
    return opFactory.privilegeRedemptionCreate(
      opId: opId,
      houseId: houseId,
      redemptionId: redemptionId,
      memberId: memberId,
      privilegeId: privilegeId,
      cycleId: cycleId,
      pointCost: pointCost,
    );
  }

  Future<void> seedHousemate({
    required String houseId,
    required String memberId,
    MemberStatus status = MemberStatus.active,
  }) async {
    await db
        .into(db.housematesSync)
        .insert(
          HousematesSyncCompanion.insert(
            memberId: memberId,
            houseId: houseId,
            tailscaleUserId: 'user-$memberId',
            tailscaleNodeKey: 'node-$memberId',
            nickname: 'Mate $memberId',
            memberStatus: status.wireValue,
            updatedAtHlc: hlcService.toBytes(hlcService.now()),
          ),
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
      payload: {'cycle_id': cycleId, if (from != null) 'from': from, 'to': to},
    );
  }
}
