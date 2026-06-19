import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/repositories/house_repositories.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/services/sync_coordinator.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';
import 'package:rumah/sync/ceremony_merge_side_effect_handler.dart';
import 'package:rumah/sync/hlc.dart';
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
    required this.syncCoordinator,
    required this.joinCredentialService,
  });

  final AppDatabase db;
  final DeviceIdentityService deviceIdentity;
  final HlcService hlcService;
  final DriftHouseRepository houseRepository;
  final HousemateRepository housemateRepository;
  final AuditLogRepository auditLogRepository;
  final SyncCoordinator syncCoordinator;
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

final syncCoordinatorProvider = Provider<SyncCoordinator>(
  (ref) => ref.watch(appStateProvider).syncCoordinator,
);

final joinCredentialServiceProvider = Provider<JoinCredentialService>(
  (ref) => ref.watch(appStateProvider).joinCredentialService,
);

Future<AppState> createAppState({
  AppDatabase? testDatabase,
  bool startSync = true,
  String? testDeviceId,
  String? testNodeKey,
}) async {
  final db = testDatabase ?? await openAppDatabase();
  final identity = DeviceIdentityService();
  final deviceId =
      testDeviceId ?? await identity.getOrCreateDeviceId();
  final nodeKey = testNodeKey ?? await identity.getOrCreateNodeKey();

  final hlcService = HlcService(deviceId: deviceId);
  final hlcBytes = hlcService.toBytes(hlcService.now());

  final existingSettings =
      await (db.select(db.localUserSettings)).getSingleOrNull();
  if (existingSettings == null) {
    await db.into(db.localUserSettings).insert(
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

  final mergeEngine = MergeEngine(db);
  final sideEffectHandler = CeremonyMergeSideEffectHandler(db);
  final syncWriteCoordinator = SyncWriteCoordinator(
    db: db,
    hlcService: hlcService,
    deviceId: deviceId,
    mergeEngine: mergeEngine,
    sideEffectHandler: sideEffectHandler,
  );
  final joinCredentialService = JoinCredentialService();

  final dir = testDatabase != null
      ? null
      : await getApplicationSupportDirectory();
  final meshService = TailscaleMeshService(
    stateDirectory: dir != null
        ? p.join(dir.path, 'tailscale')
        : '/tmp/rumah-test-tailscale',
  );
  final transport = TailscaleSyncTransport();

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

  final syncCoordinator = SyncCoordinator(
    db: db,
    syncWriteCoordinator: syncWriteCoordinator,
    meshService: meshService,
    transport: transport,
    joinCredentialService: joinCredentialService,
  );

  if (startSync) {
    await syncCoordinator.start();
  }

  return AppState(
    db: db,
    deviceIdentity: identity,
    hlcService: hlcService,
    houseRepository: houseRepository,
    housemateRepository: housemateRepository,
    auditLogRepository: auditLogRepository,
    syncCoordinator: syncCoordinator,
    joinCredentialService: joinCredentialService,
  );
}
