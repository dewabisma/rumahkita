import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/domain/generate_random_nickname.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/services/tailscale_identity_binder.dart';
import 'package:rumah/services/join_invite_codec.dart';
import 'package:rumah/services/tailscale_admin_api.dart';
import 'package:uuid/uuid.dart';

class OnboardingState {
  const OnboardingState({
    this.phase = LobbyPhase.idle,
    this.errorMessage,
    this.houseId,
    this.invite,
    this.inviteLink,
    this.pendingJoinInvite,
    this.joinAttemptGeneration = 0,
  });

  final LobbyPhase phase;
  final String? errorMessage;
  final String? houseId;
  final JoinInvitePayload? invite;
  final String? inviteLink;
  final JoinInvitePayload? pendingJoinInvite;
  final int joinAttemptGeneration;

  OnboardingState copyWith({
    LobbyPhase? phase,
    String? errorMessage,
    String? houseId,
    JoinInvitePayload? invite,
    String? inviteLink,
    JoinInvitePayload? pendingJoinInvite,
    int? joinAttemptGeneration,
    bool clearError = false,
    bool clearPendingJoinInvite = false,
  }) {
    return OnboardingState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      houseId: houseId ?? this.houseId,
      invite: invite ?? this.invite,
      inviteLink: inviteLink ?? this.inviteLink,
      pendingJoinInvite: clearPendingJoinInvite
          ? null
          : (pendingJoinInvite ?? this.pendingJoinInvite),
      joinAttemptGeneration:
          joinAttemptGeneration ?? this.joinAttemptGeneration,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  final _uuid = const Uuid();

  @override
  OnboardingState build() => const OnboardingState();

  Future<void> bootstrapHost({
    required String displayName,
    required String tailscaleAuthKey,
    required String tailscaleAdminApiKey,
  }) async {
    state = state.copyWith(
      phase: LobbyPhase.connectingTailscale,
      clearError: true,
    );
    try {
      final mesh = ref.read(meshServiceProvider);
      final localSettings = ref.read(localSettingsRepositoryProvider);
      final houseRepo = ref.read(houseRepositoryProvider);
      final housemateRepo = ref.read(housemateRepositoryProvider);
      final sync = ref.read(syncServiceProvider);

      await localSettings.setTailscaleAuthKey(tailscaleAuthKey);
      await localSettings.setTailscaleAdminApiKey(tailscaleAdminApiKey);
      await mesh.up(authKey: tailscaleAuthKey);
      await _bindTailscaleNodeKeyFromAdminApi(localSettings);

      final memberId = _uuid.v4();
      final house = await houseRepo.createHouse(
        displayName: displayName,
        creatorMemberId: memberId,
      );
      final nodeKey = await localSettings.getTailscaleNodeKey();
      final deviceId = await localSettings.getDeviceId();
      final nickname = generateRandomNickname();

      await housemateRepo.addCreatorHousemate(
        houseId: house.houseId,
        memberId: memberId,
        tailscaleUserId: 'user-$deviceId',
        tailscaleNodeKey: nodeKey,
        nickname: nickname,
      );

      await localSettings.setBootstrapHostNodeKey(nodeKey);
      final built = await _buildFullInvite(house.houseId);

      state = state.copyWith(
        phase: LobbyPhase.ready,
        houseId: house.houseId,
        invite: built.invite,
        inviteLink: built.link,
      );

      await sync.drainOutbox();
    } on Object catch (e) {
      state = state.copyWith(
        phase: LobbyPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _bindTailscaleNodeKeyFromAdminApi(
    LocalSettingsRepository localSettings,
  ) async {
    final adminApi = await createTailscaleAdminApi(localSettings);
    await resolveAndBindTailscaleNodeKey(
      localSettings: localSettings,
      deviceIdentity: ref.read(deviceIdentityProvider),
      adminApi: adminApi,
    );
  }

  Future<void> regenerateInvite() async {
    final houseId =
        state.houseId ?? await ref.read(activeHouseIdProvider.future);
    if (houseId == null) {
      return;
    }
    final built = await _buildFullInvite(houseId);
    state = state.copyWith(invite: built.invite, inviteLink: built.link);
  }

  Future<({JoinInvitePayload invite, String link})> _buildFullInvite(
    String houseId,
  ) async {
    final mesh = ref.read(meshServiceProvider);
    final localSettings = ref.read(localSettingsRepositoryProvider);
    final authKey = await localSettings.getTailscaleAuthKey();
    if (authKey == null || authKey.isEmpty) {
      throw StateError('Tailscale auth key is required to build an invite');
    }
    final nodeKey = await localSettings.getTailscaleNodeKey();
    final magicDns = mesh.localMagicDns ?? 'localhost';
    final base = await ref
        .read(houseRepositoryProvider)
        .buildInvite(
          houseId: houseId,
          hostNodeKey: nodeKey,
          hostMagicDns: magicDns,
        );
    final invite = base.copyWith(tailscaleAuthKey: authKey);
    final link = ref.read(joinInviteCodecProvider).encode(invite);
    return (invite: invite, link: link);
  }

  void setPendingJoinInvite(JoinInvitePayload invite) {
    if (invite.payloadVersion != joinInvitePayloadVersion) {
      throw FormatException(
        'Unsupported invite version ${invite.payloadVersion}',
      );
    }
    if (invite.tailscaleAuthKey.isEmpty) {
      throw const FormatException('Invite is missing Tailscale auth key');
    }
    state = state.copyWith(
      pendingJoinInvite: invite,
      clearError: true,
      phase: LobbyPhase.idle,
    );
  }

  bool _isJoinAttemptStale(int generation) {
    return generation != state.joinAttemptGeneration ||
        state.pendingJoinInvite == null;
  }

  Future<void> connectJoiner() async {
    final invite = state.pendingJoinInvite;
    if (invite == null) {
      throw StateError('No pending join invite');
    }

    final generation = state.joinAttemptGeneration;

    state = state.copyWith(
      phase: LobbyPhase.connectingTailscale,
      clearError: true,
    );
    try {
      final mesh = ref.read(meshServiceProvider);
      final localSettings = ref.read(localSettingsRepositoryProvider);
      final housemateRepo = ref.read(housemateRepositoryProvider);
      final sync = ref.read(syncServiceProvider);

      await localSettings.setTailscaleAuthKey(invite.tailscaleAuthKey);
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      await mesh.up(authKey: invite.tailscaleAuthKey);
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      state = state.copyWith(phase: LobbyPhase.catchingUp);
      final deviceId = await localSettings.getDeviceId();
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      final nodeKey = await localSettings.getTailscaleNodeKey();
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      final catchUpRequest = CatchUpRequest(
        deviceId: deviceId,
        tailscaleNodeKey: nodeKey,
        houseId: invite.houseId,
        inviteHostNodeKey: invite.hostNodeKey,
        joinCredential: invite.joinCredential,
      );

      final response = await sync.performCatchUp(
        hostMagicDns: invite.hostMagicDns,
        request: catchUpRequest,
      );
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      await sync.persistHouseJoinSecret(
        houseId: invite.houseId,
        secretBase64: response.houseJoinSecret,
      );
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      state = state.copyWith(phase: LobbyPhase.replayingHistory);
      await sync.applyRosterSnapshot(
        houseId: invite.houseId,
        rosterSnapshot: response.rosterSnapshot,
      );
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      await sync.replayCatchUpOutbox(
        houseId: invite.houseId,
        trustedHostNodeKey: invite.hostNodeKey,
        envelopes: response.outboxReplay,
      );
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      state = state.copyWith(phase: LobbyPhase.joiningHouse);
      final memberId = _uuid.v4();
      final nickname = generateRandomNickname();
      final rotationIndex = await housemateRepo.nextRotationIndex(
        invite.houseId,
      );
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      await housemateRepo.joinHousemate(
        houseId: invite.houseId,
        memberId: memberId,
        tailscaleUserId: 'user-$deviceId',
        tailscaleNodeKey: nodeKey,
        nickname: nickname,
        rotationOrderIndex: rotationIndex,
        joinCredential: invite.joinCredential,
      );
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      await localSettings.setActiveHouseId(invite.houseId);
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      await localSettings.setBootstrapHostNodeKey(invite.hostNodeKey);
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      state = state.copyWith(phase: LobbyPhase.syncing);
      await sync.drainOutbox();
      if (_isJoinAttemptStale(generation)) {
        return;
      }

      state = state.copyWith(
        phase: LobbyPhase.ready,
        houseId: invite.houseId,
        clearPendingJoinInvite: true,
      );
    } on Object catch (e) {
      if (_isJoinAttemptStale(generation)) {
        return;
      }
      state = state.copyWith(
        phase: LobbyPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> abortJoiner() async {
    final invite = state.pendingJoinInvite;
    final houseId = invite?.houseId;

    state = state.copyWith(
      joinAttemptGeneration: state.joinAttemptGeneration + 1,
      clearPendingJoinInvite: true,
      phase: LobbyPhase.idle,
      clearError: true,
    );

    final localSettings = ref.read(localSettingsRepositoryProvider);
    final mesh = ref.read(meshServiceProvider);
    final sync = ref.read(syncServiceProvider);

    if (houseId != null) {
      await sync.discardPartialJoin(houseId);
    }
    await localSettings.setActiveHouseId(null);
    await localSettings.setBootstrapHostNodeKey(null);
    await localSettings.setTailscaleAuthKey(null);
    await mesh.down();
    await mesh.clearAuthKey();
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

final joinInviteCodecProvider = Provider<JoinInviteCodec>(
  (ref) => const JoinInviteCodec(),
);

final activeHouseIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(localSettingsRepositoryProvider).watchActiveHouseId();
});

final pendingOpCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final activeHouseId = ref.watch(
    activeHouseIdProvider.select((async) => async.asData?.value),
  );
  if (activeHouseId == null || activeHouseId.isEmpty) {
    return Stream.value(0);
  }
  final query = db.select(db.syncOutboxEntries)
    ..where(
      (t) => t.houseId.equals(activeHouseId) & t.broadcasted.equals(false),
    );
  return query.watch().map((rows) => rows.length);
});

final isHouseCreatorProvider = FutureProvider<bool>((ref) async {
  final houseId = await ref.watch(activeHouseIdProvider.future);
  if (houseId == null) {
    return false;
  }
  final localMember = await ref.watch(localMemberProvider.future);
  if (localMember == null) {
    return false;
  }
  final house = await ref.watch(houseProvider(houseId).future);
  return house?.creatorMemberId == localMember.memberId;
});

/// True when this device registered the house and can generate join invites.
final canShareInviteProvider = FutureProvider<bool>((ref) async {
  final localSettings = ref.read(localSettingsRepositoryProvider);
  final authKey = await localSettings.getTailscaleAuthKey();
  if (authKey == null || authKey.isEmpty) {
    return false;
  }

  final bootstrapHost = await localSettings.getBootstrapHostNodeKey();
  if (bootstrapHost == null || bootstrapHost.isEmpty) {
    return false;
  }

  final nodeKey = await localSettings.getTailscaleNodeKey();
  if (nodeKey == bootstrapHost) {
    return true;
  }

  return ref.watch(isHouseCreatorProvider.future);
});

final localMemberProvider = FutureProvider<Housemate?>((ref) async {
  final houseId = await ref.watch(activeHouseIdProvider.future);
  if (houseId == null) {
    return null;
  }
  final nodeKey = await ref
      .watch(localSettingsRepositoryProvider)
      .getTailscaleNodeKey();
  final mates = ref.watch(housematesProvider(houseId)).asData?.value ?? [];
  final match = mates.where((m) => m.tailscaleNodeKey == nodeKey).firstOrNull;
  return match;
});

final houseProvider = FutureProvider.family<House?, String>((
  ref,
  houseId,
) async {
  final db = ref.watch(databaseProvider);
  final row = await (db.select(
    db.houseSync,
  )..where((t) => t.houseId.equals(houseId))).getSingleOrNull();
  if (row == null) {
    return null;
  }
  return House(
    houseId: row.houseId,
    displayName: row.displayName,
    creatorMemberId: row.creatorMemberId,
    rulesVersion: row.rulesVersion,
    createdAtHlc: row.createdAtHlc,
    updatedAtHlc: row.updatedAtHlc,
  );
});

final housematesProvider = StreamProvider.family<List<Housemate>, String>((
  ref,
  houseId,
) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.housematesSync)
    ..where((t) => t.houseId.equals(houseId));
  return query.watch().map((rows) {
    final sorted = [...rows]
      ..sort(
        (a, b) =>
            (a.rotationOrderIndex ?? 0).compareTo(b.rotationOrderIndex ?? 0),
      );
    return sorted
        .map(
          (row) => Housemate(
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
          ),
        )
        .toList();
  });
});
