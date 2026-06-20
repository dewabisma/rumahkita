import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/state_machines/task_status_machine.dart';

void main() {
  group('TaskStatusMachine', () {
    test('allows open to pendingReview and archived', () {
      expect(
        TaskStatusMachine.canTransition(
          TaskStatus.open,
          TaskStatus.pendingReview,
        ),
        isTrue,
      );
      expect(
        TaskStatusMachine.canTransition(TaskStatus.open, TaskStatus.archived),
        isTrue,
      );
    });

    test('allows pendingReview to open and approved', () {
      expect(
        TaskStatusMachine.canTransition(
          TaskStatus.pendingReview,
          TaskStatus.open,
        ),
        isTrue,
      );
      expect(
        TaskStatusMachine.canTransition(
          TaskStatus.pendingReview,
          TaskStatus.approved,
        ),
        isTrue,
      );
    });

    test('terminal states reject transitions', () {
      expect(
        TaskStatusMachine.canTransition(TaskStatus.approved, TaskStatus.open),
        isFalse,
      );
      expect(
        TaskStatusMachine.canTransition(TaskStatus.archived, TaskStatus.open),
        isFalse,
      );
    });

    test('claimed and rejected are never valid targets in phase 3', () {
      expect(
        TaskStatusMachine.canTransition(TaskStatus.open, TaskStatus.claimed),
        isFalse,
      );
      expect(
        TaskStatusMachine.canTransition(
          TaskStatus.pendingReview,
          TaskStatus.rejected,
        ),
        isFalse,
      );
    });
  });
}
