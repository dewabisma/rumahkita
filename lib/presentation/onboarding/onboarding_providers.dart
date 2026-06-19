import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';
import 'package:rumah/domain/enums/lobby_phase.dart';
import 'package:rumah/services/catch_up_protocol.dart';
import 'package:rumah/services/join_invite_codec.dart';
import 'package:uuid/uuid.dart';

class OnboardingState {
  const OnboardingState({
    this.phase = LobbyPhase.idle,
    this.errorMessage,
    this.houseId,
    this.invite,
    this.inviteLink,
  });

  final LobbyPhase phase;
  final String? errorMessage;
  final String? houseId;
  final JoinInvitePayload? invite;
  final String? inviteLink;

  OnboardingState copyWith({
    LobbyPhase? phase,
    String? errorMessage,
    String? houseId,
    JoinInvitePayload? invite,
    String? inviteLink,
    bool clearError = false,
  }) {
    return OnboardingState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      houseId: houseId ?? this.houseId,
      invite: invite ?? this.invite,
      inviteLink: inviteLink ?? this.inviteLink,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  final _uuid = const Uuid();

  @override
  OnboardingState build() => const OnboardingState();

  Future<void> bootstrapHost({
    required String displayName,
    required String nickname,
    String? tailscaleAuthKey,
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

      if (tailscaleAuthKey != null && tailscaleAuthKey.isNotEmpty) {
        await localSettings.setTailscaleAuthKey(tailscaleAuthKey);
      }
      await mesh.up(authKey: tailscaleAuthKey);

      final memberId = _uuid.v4();
      final house = await houseRepo.createHouse(
        displayName: displayName,
        creatorMemberId: memberId,
      );
      final nodeKey = await localSettings.getTailscaleNodeKey();
      final deviceId = await localSettings.getDeviceId();

      await housemateRepo.addCreatorHousemate(
        houseId: house.houseId,
        memberId: memberId,
        tailscaleUserId: 'user-$deviceId',
        tailscaleNodeKey: nodeKey,
        nickname: nickname,
      );

      await localSettings.setBootstrapHostNodeKey(nodeKey);
      final magicDns = mesh.localMagicDns ?? 'localhost';
      final invite = await houseRepo.buildInvite(
        houseId: house.houseId,
        hostNodeKey: nodeKey,
        hostMagicDns: magicDns,
      );
      final link = ref.read(joinInviteCodecProvider).encode(invite);

      state = state.copyWith(
        phase: LobbyPhase.ready,
        houseId: house.houseId,
        invite: invite,
        inviteLink: link,
      );

      await sync.drainOutbox();
    } on Object catch (e) {
      state = state.copyWith(
        phase: LobbyPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> regenerateInvite() async {
    final houseId = state.houseId ?? await ref.read(activeHouseIdProvider.future);
    if (houseId == null) {
      return;
    }
    final mesh = ref.read(meshServiceProvider);
    final localSettings = ref.read(localSettingsRepositoryProvider);
    final nodeKey = await localSettings.getTailscaleNodeKey();
    final magicDns = mesh.localMagicDns ?? 'localhost';
    final invite = await ref.read(houseRepositoryProvider).buildInvite(
          houseId: houseId,
          hostNodeKey: nodeKey,
          hostMagicDns: magicDns,
        );
    final link = ref.read(joinInviteCodecProvider).encode(invite);
    state = state.copyWith(invite: invite, inviteLink: link);
  }

  Future<void> bootstrapJoiner({
    required JoinInvitePayload invite,
    required String nickname,
    String? tailscaleAuthKey,
  }) async {
    state = state.copyWith(
      phase: LobbyPhase.connectingTailscale,
      clearError: true,
    );
    try {
      final mesh = ref.read(meshServiceProvider);
      final localSettings = ref.read(localSettingsRepositoryProvider);
      final housemateRepo = ref.read(housemateRepositoryProvider);
      final sync = ref.read(syncServiceProvider);

      if (tailscaleAuthKey != null && tailscaleAuthKey.isNotEmpty) {
        await localSettings.setTailscaleAuthKey(tailscaleAuthKey);
      }
      await mesh.up(authKey: tailscaleAuthKey);

      state = state.copyWith(phase: LobbyPhase.catchingUp);
      final deviceId = await localSettings.getDeviceId();
      final nodeKey = await localSettings.getTailscaleNodeKey();

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

      await sync.persistHouseJoinSecret(
        houseId: invite.houseId,
        secretBase64: response.houseJoinSecret,
      );

      state = state.copyWith(phase: LobbyPhase.replayingHistory);
      await sync.applyRosterSnapshot(
        houseId: invite.houseId,
        rosterSnapshot: response.rosterSnapshot,
      );
      await sync.replayCatchUpOutbox(
        houseId: invite.houseId,
        trustedHostNodeKey: invite.hostNodeKey,
        envelopes: response.outboxReplay,
      );

      await localSettings.setActiveHouseId(invite.houseId);
      await localSettings.setBootstrapHostNodeKey(invite.hostNodeKey);

      state = state.copyWith(phase: LobbyPhase.joiningHouse);
      final memberId = _uuid.v4();
      final rotationIndex =
          await housemateRepo.nextRotationIndex(invite.houseId);

      await housemateRepo.joinHousemate(
        houseId: invite.houseId,
        memberId: memberId,
        tailscaleUserId: 'user-$deviceId',
        tailscaleNodeKey: nodeKey,
        nickname: nickname,
        rotationOrderIndex: rotationIndex,
        joinCredential: invite.joinCredential,
      );

      state = state.copyWith(phase: LobbyPhase.syncing);
      await sync.drainOutbox();

      state = state.copyWith(
        phase: LobbyPhase.ready,
        houseId: invite.houseId,
      );
    } on Object catch (e) {
      state = state.copyWith(
        phase: LobbyPhase.error,
        errorMessage: e.toString(),
      );
    }
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

final localMemberProvider = FutureProvider<Housemate?>((ref) async {
  final houseId = await ref.watch(activeHouseIdProvider.future);
  if (houseId == null) {
    return null;
  }
  final nodeKey =
      await ref.watch(localSettingsRepositoryProvider).getTailscaleNodeKey();
  final mates = ref.watch(housematesProvider(houseId)).asData?.value ?? [];
  final match = mates.where((m) => m.tailscaleNodeKey == nodeKey).firstOrNull;
  return match;
});

final houseProvider = FutureProvider.family<House?, String>((ref, houseId) async {
  final db = ref.watch(databaseProvider);
  final row = await (db.select(db.houseSync)
        ..where((t) => t.houseId.equals(houseId)))
      .getSingleOrNull();
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

final housematesProvider =
    StreamProvider.family<List<Housemate>, String>((ref, houseId) {
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
