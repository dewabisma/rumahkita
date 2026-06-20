import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/entities/join_invite_payload.dart';

abstract class HouseRepository {
  Future<House> createHouse({
    required String displayName,
    required String creatorMemberId,
  });

  Future<String> generateJoinCredential(String houseId);

  Future<JoinInvitePayload> buildInvite({
    required String houseId,
    required String hostNodeKey,
    required String hostMagicDns,
  });
}

abstract class HousemateRepository {
  Future<Housemate> addCreatorHousemate({
    required String houseId,
    required String memberId,
    required String tailscaleUserId,
    required String tailscaleNodeKey,
    required String nickname,
  });

  Future<Housemate> joinHousemate({
    required String houseId,
    required String memberId,
    required String tailscaleUserId,
    required String tailscaleNodeKey,
    required String nickname,
    required int rotationOrderIndex,
    String? joinCredential,
  });

  Future<int> nextRotationIndex(String houseId);

  Future<Housemate> updateNickname({
    required String houseId,
    required String memberId,
    required String nickname,
  });
}

abstract class AuditLogRepository {
  Future<AuditLogEntry> appendEntry({
    required String houseId,
    required String taskId,
    required String actorMemberId,
    required String action,
    String? justificationNotes,
  });
}
