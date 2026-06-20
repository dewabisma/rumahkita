import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/data/repositories/drift_ceremony_repository.dart';
import 'package:rumah/data/repositories/drift_task_repository.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/data/repositories/secure_key_value_store.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/services/stub_tailscale_admin_api.dart';
import 'package:rumah/services/sync_service.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';

import '../sync/sync_test_harness.dart';

const _testAuthKey = 'tskey-auth-kABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

JoinInvitePayload _sampleInvite({String houseId = 'house-join-test'}) {
  return JoinInvitePayload(
    payloadVersion: joinInvitePayloadVersion,
    houseId: houseId,
    hostNodeKey: 'node-host',
    hostMagicDns: 'localhost',
    joinCredential: 'join-cred-test',
    tailscaleAuthKey: _testAuthKey,
  );
}

class GatedCatchUpSyncService extends SyncService {
  GatedCatchUpSyncService({
    required super.db,
    required super.syncWriteCoordinator,
    required super.meshService,
    required super.transport,
    required super.joinCredentialService,
    required super.localSettings,
    required this.catchUpEntered,
    required this.catchUpRelease,
  });

  final Completer<void> catchUpEntered;
  final Completer<void> catchUpRelease;

  @override
  Future<CatchUpResponse> performCatchUp({
    required String hostMagicDns,
    required CatchUpRequest request,
  }) async {
    if (!catchUpEntered.isCompleted) {
      catchUpEntered.complete();
    }
    await catchUpRelease.future;
    return const CatchUpResponse(
      houseJoinSecret: 'dGVzdC1zZWNyZXQ=',
      rosterSnapshot: [],
      outboxReplay: [],
    );
  }
}

Future<ProviderContainer> _container(
  SyncTestHarness harness, {
  SyncService? syncService,
  TailscaleMeshService? meshService,
}) async {
  final secureStore = InMemorySecureKeyValueStore();
  final mesh = meshService ??
      TailscaleMeshService(
        stateDirectory: '/tmp/join-abort-test',
        secureStore: secureStore,
      );
  final sync = syncService ??
      SyncService(
        db: harness.db,
        syncWriteCoordinator: harness.syncCoordinator,
        meshService: mesh,
        transport: TailscaleSyncTransport(),
        joinCredentialService: harness.joinCredentialService,
        localSettings: harness.localSettingsRepository,
      );

  final appState = AppState(
    db: harness.db,
    deviceIdentity: DeviceIdentityService(),
    hlcService: harness.hlcService,
    houseRepository: harness.houseRepository,
    housemateRepository: harness.housemateRepository,
    auditLogRepository: harness.auditLogRepository,
    ceremonyRepository: DriftCeremonyRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    ),
    taskRepository: DriftTaskRepository(
      db: harness.db,
      sync: harness.syncCoordinator,
    ),
    removalRepository: harness.removalRepository,
    syncWriteCoordinator: harness.syncCoordinator,
    localSettingsRepository: harness.localSettingsRepository,
    syncService: sync,
    meshService: mesh,
    joinCredentialService: harness.joinCredentialService,
    tailscaleAdminApi: StubTailscaleAdminApi(),
  );

  return ProviderContainer(
    overrides: [appStateProvider.overrideWithValue(appState)],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('abortJoiner clears state without error phase', () async {
    final joiner = await SyncTestHarness.create(
      deviceId: 'joiner-device',
      nodeKey: 'node-joiner',
    );
    final container = await _container(joiner);
    addTearDown(container.dispose);

    final notifier = container.read(onboardingNotifierProvider.notifier);
    notifier.setPendingJoinInvite(_sampleInvite());
    await joiner.localSettingsRepository.setTailscaleAuthKey(_testAuthKey);

    await notifier.abortJoiner();

    final state = container.read(onboardingNotifierProvider);
    expect(state.pendingJoinInvite, isNull);
    expect(state.phase, LobbyPhase.idle);
    expect(state.errorMessage, isNull);
    expect(state.joinAttemptGeneration, 1);

    expect(
      await joiner.localSettingsRepository.getActiveHouseId(),
      isNull,
    );
    expect(
      await joiner.localSettingsRepository.getTailscaleAuthKey(),
      isNull,
    );
    expect(
      await joiner.localSettingsRepository.getBootstrapHostNodeKey(),
      isNull,
    );
  });

  test(
    'connectJoiner respects stale generation after abort (does not set activeHouseId)',
    () async {
      final joiner = await SyncTestHarness.create(
        deviceId: 'joiner-device',
        nodeKey: 'node-joiner',
      );
      final catchUpEntered = Completer<void>();
      final catchUpRelease = Completer<void>();
      final secureStore = InMemorySecureKeyValueStore();
      final mesh = TailscaleMeshService(
        stateDirectory: '/tmp/join-abort-gate',
        secureStore: secureStore,
      );
      final gatedSync = GatedCatchUpSyncService(
        db: joiner.db,
        syncWriteCoordinator: joiner.syncCoordinator,
        meshService: mesh,
        transport: TailscaleSyncTransport(),
        joinCredentialService: joiner.joinCredentialService,
        localSettings: joiner.localSettingsRepository,
        catchUpEntered: catchUpEntered,
        catchUpRelease: catchUpRelease,
      );
      final container = await _container(
        joiner,
        syncService: gatedSync,
        meshService: mesh,
      );
      addTearDown(container.dispose);

      final notifier = container.read(onboardingNotifierProvider.notifier);
      notifier.setPendingJoinInvite(_sampleInvite());

      final connectFuture = notifier.connectJoiner();
      await catchUpEntered.future;

      await notifier.abortJoiner();
      catchUpRelease.complete();

      await connectFuture;

      final state = container.read(onboardingNotifierProvider);
      expect(state.phase, isNot(LobbyPhase.error));
      expect(state.phase, LobbyPhase.idle);
      expect(state.pendingJoinInvite, isNull);
      expect(state.joinAttemptGeneration, 1);

      expect(
        await joiner.localSettingsRepository.getActiveHouseId(),
        isNull,
      );
    },
  );
}
