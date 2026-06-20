import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_house_repositories.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/domain/repositories/task_repository.dart';
import 'package:rumah/sync/sync_operation.dart';
import 'package:uuid/uuid.dart';

class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository({
    required AppDatabase db,
    required SyncWriteCoordinator sync,
    Uuid? uuid,
  }) : _db = db,
       _sync = sync,
       _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncWriteCoordinator _sync;
  final Uuid _uuid;

  @override
  Future<void> claim({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  }) async {
    final claimOp = _sync.opFactory.taskClaim(
      opId: _uuid.v4(),
      houseId: houseId,
      eventId: _uuid.v4(),
      taskId: taskId,
      memberId: actorMemberId,
    );
    await _emit(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [claimOp],
    );
  }

  @override
  Future<void> submitForReview({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  }) async {
    final statusOp = _sync.opFactory.taskStatusUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      actorMemberId: actorMemberId,
      from: TaskStatus.open,
      to: TaskStatus.pendingReview,
    );
    final auditOp = _sync.opFactory.auditLogAppend(
      opId: _uuid.v4(),
      houseId: houseId,
      logId: _uuid.v4(),
      taskId: taskId,
      actorMemberId: actorMemberId,
      action: 'submit_for_review',
    );
    await _emit(
      houseId: houseId,
      senderMemberId: actorMemberId,
      ops: [statusOp, auditOp],
    );
  }

  @override
  Future<void> approve({
    required String houseId,
    required String taskId,
    required String guardianMemberId,
  }) async {
    final statusOp = _sync.opFactory.taskStatusUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      actorMemberId: guardianMemberId,
      from: TaskStatus.pendingReview,
      to: TaskStatus.approved,
    );
    final auditOp = _sync.opFactory.auditLogAppend(
      opId: _uuid.v4(),
      houseId: houseId,
      logId: _uuid.v4(),
      taskId: taskId,
      actorMemberId: guardianMemberId,
      action: 'approve',
    );
    await _emit(
      houseId: houseId,
      senderMemberId: guardianMemberId,
      ops: [statusOp, auditOp],
    );
  }

  @override
  Future<void> reject({
    required String houseId,
    required String taskId,
    required String guardianMemberId,
    String? justificationNotes,
  }) async {
    final statusOp = _sync.opFactory.taskStatusUpdate(
      opId: _uuid.v4(),
      houseId: houseId,
      taskId: taskId,
      actorMemberId: guardianMemberId,
      from: TaskStatus.pendingReview,
      to: TaskStatus.open,
    );
    final auditOp = _sync.opFactory.auditLogAppend(
      opId: _uuid.v4(),
      houseId: houseId,
      logId: _uuid.v4(),
      taskId: taskId,
      actorMemberId: guardianMemberId,
      action: 'reject',
      justificationNotes: justificationNotes,
    );
    await _emit(
      houseId: houseId,
      senderMemberId: guardianMemberId,
      ops: [statusOp, auditOp],
    );
  }

  Future<void> _emit({
    required String houseId,
    required String? senderMemberId,
    required List<SyncOperation> ops,
  }) async {
    final settings = await (_db.select(
      _db.localUserSettings,
    )).getSingleOrNull();
    final result = await _sync.emitLocalOps(
      houseId: houseId,
      tailscaleNodeKey: settings?.tailscaleNodeId ?? 'local-node',
      senderMemberId: senderMemberId,
      ops: ops,
    );
    if (result.rejectedOpIds.isNotEmpty) {
      throw TaskOperationException(result.error ?? 'merge rejected');
    }
  }
}

class TaskOperationException implements Exception {
  TaskOperationException(this.message);

  final String message;

  @override
  String toString() => message;
}
