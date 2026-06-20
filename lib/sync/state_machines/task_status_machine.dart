import 'package:rumah/domain/enums/task_status.dart';

class TaskStatusMachine {
  TaskStatusMachine._();

  static bool canTransition(TaskStatus? from, TaskStatus to) {
    if (from == null) {
      return to == TaskStatus.open;
    }
    switch (from) {
      case TaskStatus.open:
        return to == TaskStatus.pendingReview || to == TaskStatus.archived;
      case TaskStatus.pendingReview:
        return to == TaskStatus.open || to == TaskStatus.approved;
      case TaskStatus.approved:
      case TaskStatus.archived:
      case TaskStatus.claimed:
      case TaskStatus.rejected:
        return false;
    }
  }
}
