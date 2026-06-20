abstract class TaskRepository {
  Future<void> claim({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  });

  Future<void> submitForReview({
    required String houseId,
    required String taskId,
    required String actorMemberId,
  });

  Future<void> approve({
    required String houseId,
    required String taskId,
    required String guardianMemberId,
  });

  Future<void> reject({
    required String houseId,
    required String taskId,
    required String guardianMemberId,
    String? justificationNotes,
  });
}
