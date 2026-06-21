import 'package:rumah/domain/entities/house_privilege.dart';
import 'package:rumah/domain/entities/privilege_redemption.dart';
import 'package:rumah/domain/entities/cycle.dart';
import 'package:rumah/domain/entities/task.dart';

abstract class CeremonyRepository {
  Future<Cycle> startCeremony(String houseId);

  Future<Cycle> startNextCycleCeremony({
    required String houseId,
    required String handoverCycleId,
    required String actorMemberId,
  });

  Future<void> advanceHandoverStep({
    required String houseId,
    required String cycleId,
    required String actorMemberId,
    required String from,
    required String to,
  });

  Future<void> expireCycleToHandover({
    required String houseId,
    required String cycleId,
  });

  Future<Task> addTask({
    required String houseId,
    required String cycleId,
    required String title,
    required String description,
    required int points,
    required String actorMemberId,
    String assignedToMemberId = '',
  });

  Future<void> updateTaskTitle({
    required String houseId,
    required String taskId,
    required String title,
    required String actorMemberId,
  });

  Future<void> updateTaskDescription({
    required String houseId,
    required String taskId,
    required String description,
    required String actorMemberId,
  });

  Future<void> updateTaskPoints({
    required String houseId,
    required String taskId,
    required int points,
    required String actorMemberId,
  });

  Future<void> updateTaskAssignee({
    required String houseId,
    required String taskId,
    required String assignedToMemberId,
    required String actorMemberId,
  });

  Future<void> archiveTask({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  });

  Future<HousePrivilege> addPrivilege({
    required String houseId,
    required String cycleId,
    required String name,
    required String description,
    required int pointCost,
    required String actorMemberId,
  });

  Future<void> updatePrivilegeName({
    required String houseId,
    required String privilegeId,
    required String name,
    required String actorMemberId,
  });

  Future<void> updatePrivilegeDescription({
    required String houseId,
    required String privilegeId,
    required String description,
    required String actorMemberId,
  });

  Future<void> updatePrivilegePointCost({
    required String houseId,
    required String privilegeId,
    required int pointCost,
    required String actorMemberId,
  });

  Future<void> archivePrivilege({
    required String houseId,
    required String privilegeId,
    required String actorMemberId,
  });

  Future<PrivilegeRedemption> redeemPrivilege({
    required String houseId,
    required String cycleId,
    required String privilegeId,
    required String memberId,
  });

  Future<void> consumeRedemption({
    required String houseId,
    required String redemptionId,
    required String actorMemberId,
  });

  Future<void> acceptRules({
    required String houseId,
    required String cycleId,
    required String memberId,
  });
}
