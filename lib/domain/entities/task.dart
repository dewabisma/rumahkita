import 'package:rumah/domain/enums/task_status.dart';

class Task {
  const Task({
    required this.taskId,
    required this.houseId,
    required this.cycleId,
    required this.title,
    required this.description,
    required this.negotiatedPoints,
    required this.status,
    required this.assignedToMemberId,
    required this.claimedByMemberIds,
    required this.updatedAtHlc,
  });

  final String taskId;
  final String houseId;
  final String cycleId;
  final String title;
  final String description;
  final int negotiatedPoints;
  final TaskStatus status;
  final String assignedToMemberId;
  final List<String> claimedByMemberIds;
  final List<int> updatedAtHlc;

  bool get isArchived => status == TaskStatus.archived;
  bool get isAssigned => assignedToMemberId.isNotEmpty;
}
