
sealed class MergeSideEffect {
  const MergeSideEffect();
}

class RulesVersionBumped extends MergeSideEffect {
  const RulesVersionBumped({
    required this.houseId,
    required this.oldVersion,
    required this.newVersion,
    required this.hlc,
  });

  final String houseId;
  final int oldVersion;
  final int newVersion;
  final List<int> hlc;
}

class TaskPointsChanged extends MergeSideEffect {
  const TaskPointsChanged({
    required this.taskId,
    required this.cycleId,
    required this.oldPoints,
    required this.newPoints,
    required this.hlc,
  });

  final String taskId;
  final String cycleId;
  final int oldPoints;
  final int newPoints;
  final List<int> hlc;
}

class CeremonySignoffsChanged extends MergeSideEffect {
  const CeremonySignoffsChanged({
    required this.houseId,
    required this.cycleId,
  });

  final String houseId;
  final String cycleId;
}

abstract class MergeSideEffectHandler {
  Future<void> handle(List<MergeSideEffect> effects);
}

class NoOpMergeSideEffectHandler implements MergeSideEffectHandler {
  @override
  Future<void> handle(List<MergeSideEffect> effects) async {}
}

class MergeResult {
  const MergeResult({
    required this.appliedOpIds,
    required this.rejectedOpIds,
    required this.sideEffects,
    this.error,
  });

  final List<String> appliedOpIds;
  final List<String> rejectedOpIds;
  final List<MergeSideEffect> sideEffects;
  final String? error;

  bool get success {
    if (error != null) {
      return false;
    }
    if (appliedOpIds.isEmpty && rejectedOpIds.isNotEmpty) {
      return false;
    }
    return true;
  }
}
