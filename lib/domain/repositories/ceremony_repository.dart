import 'package:rumah/domain/entities/cycle.dart';
import 'package:rumah/domain/entities/privilege_template.dart';
import 'package:rumah/domain/entities/task.dart';

abstract class CeremonyRepository {
  Future<Cycle> startCeremony(String houseId);

  Future<Task> addTask({
    required String houseId,
    required String cycleId,
    required String title,
    required int points,
    required String actorMemberId,
  });

  Future<void> updateTaskTitle({
    required String houseId,
    required String taskId,
    required String title,
    required String actorMemberId,
  });

  Future<void> updateTaskPoints({
    required String houseId,
    required String taskId,
    required int points,
    required String actorMemberId,
  });

  Future<void> archiveTask({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  });

  Future<void> updatePrivilegeTemplates({
    required String houseId,
    required Map<String, PrivilegeTemplate> templates,
    required String actorMemberId,
  });

  Future<void> acceptRules({
    required String houseId,
    required String cycleId,
    required String memberId,
  });
}
