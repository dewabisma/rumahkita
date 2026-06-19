import 'package:rumah/domain/entities/house_entities.dart';

abstract class HouseRepository {
  Future<House> createHouse({
    required String displayName,
    required String creatorMemberId,
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
