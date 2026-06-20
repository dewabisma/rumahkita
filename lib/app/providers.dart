import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/domain/repositories/ceremony_repository.dart';
import 'package:rumah/domain/repositories/house_repositories.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';
import 'package:rumah/domain/repositories/task_repository.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/ceremony_merge_side_effect_handler.dart';
import 'package:rumah/sync/handover_merge_side_effect_handler.dart';
import 'package:rumah/sync/hlc.dart';
import 'package:rumah/sync/merge_side_effect.dart';
import 'package:rumah/sync/privilege_tier_merge_side_effect_handler.dart';
import 'package:rumah/sync/join_credential.dart';
import 'package:rumah/sync/merge_engine.dart';

/// Bootstrapped app dependencies. Override [appStateProvider] at the root.
class AppState {
  const AppState({
    required this.db,
    required this.deviceIdentity,
    required this.hlcService,
    required this.houseRepository,
    required this.housemateRepository,
    required this.auditLogRepository,
    required this.ceremonyRepository,
    required this.taskRepository,
    required this.syncWriteCoordinator,
    required this.localSettingsRepository,
    required this.syncService,
    required this.meshService,
    required this.joinCredentialService,
  });

  final AppDatabase db;
  final DeviceIdentityService deviceIdentity;
  final HlcService hlcService;
  final DriftHouseRepository houseRepository;
  final HousemateRepository housemateRepository;
  final AuditLogRepository auditLogRepository;
  final CeremonyRepository ceremonyRepository;
  final TaskRepository taskRepository;
  final SyncWriteCoordinator syncWriteCoordinator;
  final LocalSettingsRepository localSettingsRepository;
  final SyncService syncService;
  final TailscaleMeshService meshService;
  final JoinCredentialService joinCredentialService;
}

final appStateProvider = Provider<AppState>(
  (ref) => throw UnimplementedError(
    'Override appStateProvider in ProviderScope after createAppState()',
  ),
);

final databaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(appStateProvider).db,
);

final houseRepositoryProvider = Provider<DriftHouseRepository>(
  (ref) => ref.watch(appStateProvider).houseRepository,
);

final housemateRepositoryProvider = Provider<HousemateRepository>(
  (ref) => ref.watch(appStateProvider).housemateRepository,
);

final auditLogRepositoryProvider = Provider<AuditLogRepository>(
  (ref) => ref.watch(appStateProvider).auditLogRepository,
);

final ceremonyRepositoryProvider = Provider<CeremonyRepository>(
  (ref) => ref.watch(appStateProvider).ceremonyRepository,
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ref.watch(appStateProvider).taskRepository,
);

final syncWriteCoordinatorProvider = Provider<SyncWriteCoordinator>(
  (ref) => ref.watch(appStateProvider).syncWriteCoordinator,
);

final localSettingsRepositoryProvider = Provider<LocalSettingsRepository>(
  (ref) => ref.watch(appStateProvider).localSettingsRepository,
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => ref.watch(appStateProvider).syncService,
);

final meshServiceProvider = Provider<TailscaleMeshService>(
  (ref) => ref.watch(appStateProvider).meshService,
);

final joinCredentialServiceProvider = Provider<JoinCredentialService>(
  (ref) => ref.watch(appStateProvider).joinCredentialService,
);

/// Backward-compatible alias for dev panel during migration.
final syncCoordinatorProvider = syncServiceProvider;

Future<AppState> createAppState({
  AppDatabase? testDatabase,
  bool startSync = true,
  String? testDeviceId,
  String? testNodeKey,
  TailscaleMeshService? testMeshService,
  TailscaleSyncTransport? testTransport,
}) async {
  final db = testDatabase ?? await openAppDatabase();
  final identity = DeviceIdentityService();
  final deviceId = testDeviceId ?? await identity.getOrCreateDeviceId();
  final nodeKey = testNodeKey ?? await identity.getOrCreateNodeKey();

  final hlcService = HlcService(deviceId: deviceId);
  final hlcBytes = hlcService.toBytes(hlcService.now());

  final existingSettings = await (db.select(
    db.localUserSettings,
  )).getSingleOrNull();
  if (existingSettings == null) {
    await db
        .into(db.localUserSettings)
        .insert(
          LocalUserSettingsCompanion.insert(
            deviceId: deviceId,
            tailscaleNodeId: Value(nodeKey),
            createdAtHlc: hlcBytes,
          ),
        );
  } else {
    await (db.update(db.localUserSettings)
          ..where((t) => t.deviceId.equals(deviceId)))
        .write(LocalUserSettingsCompanion(tailscaleNodeId: Value(nodeKey)));
  }

  final localSettingsRepository = DriftLocalSettingsRepository(db: db);
  final mergeEngine = MergeEngine(db);
  final ceremonySideEffectHandler = CeremonyMergeSideEffectHandler(db);
  final handoverSideEffectHandler = HandoverMergeSideEffectHandler(db);
  final privilegeTierSideEffectHandler = PrivilegeTierMergeSideEffectHandler(db);
  final sideEffectHandler = CompositeMergeSideEffectHandler([
    ceremonySideEffectHandler,
    handoverSideEffectHandler,
    privilegeTierSideEffectHandler,
  ]);
  final syncWriteCoordinator = SyncWriteCoordinator(
    db: db,
    hlcService: hlcService,
    deviceId: deviceId,
    mergeEngine: mergeEngine,
    sideEffectHandler: sideEffectHandler,
  );
  ceremonySideEffectHandler.bindSync(syncWriteCoordinator);
  privilegeTierSideEffectHandler.bindSync(syncWriteCoordinator);
  final joinCredentialService = JoinCredentialService();

  final dir = testDatabase != null
      ? null
      : await getApplicationSupportDirectory();
  final meshService =
      testMeshService ??
      TailscaleMeshService(
        stateDirectory: dir != null
            ? p.join(dir.path, 'tailscale')
            : '/tmp/rumah-test-tailscale',
      );
  final transport = testTransport ?? TailscaleSyncTransport();

  final houseRepository = DriftHouseRepository(
    db: db,
    sync: syncWriteCoordinator,
    joinCredentialService: joinCredentialService,
  );
  final housemateRepository = DriftHousemateRepository(
    db: db,
    sync: syncWriteCoordinator,
  );
  final auditLogRepository = DriftAuditLogRepository(
    db: db,
    sync: syncWriteCoordinator,
  );
  final ceremonyRepository = DriftCeremonyRepository(
    db: db,
    sync: syncWriteCoordinator,
  );
  final taskRepository = DriftTaskRepository(
    db: db,
    sync: syncWriteCoordinator,
  );

  final syncService = SyncService(
    db: db,
    syncWriteCoordinator: syncWriteCoordinator,
    meshService: meshService,
    transport: transport,
    joinCredentialService: joinCredentialService,
    localSettings: localSettingsRepository,
  );

  if (startSync) {
    await syncService.start();
  }

  return AppState(
    db: db,
    deviceIdentity: identity,
    hlcService: hlcService,
    houseRepository: houseRepository,
    housemateRepository: housemateRepository,
    auditLogRepository: auditLogRepository,
    ceremonyRepository: ceremonyRepository,
    taskRepository: taskRepository,
    syncWriteCoordinator: syncWriteCoordinator,
    localSettingsRepository: localSettingsRepository,
    syncService: syncService,
    meshService: meshService,
    joinCredentialService: joinCredentialService,
  );
}
