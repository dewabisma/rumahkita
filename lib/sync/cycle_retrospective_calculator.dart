import 'package:rumah/domain/entities/task.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/handover_cycle_helpers.dart';

class CycleRetrospectiveMemberStats {
  const CycleRetrospectiveMemberStats({
    required this.memberId,
    required this.startScore,
    required this.endScore,
    required this.pointsEarned,
    required this.approvedTaskCount,
    required this.neglectedOpenTasks,
  });

  final String memberId;
  final int startScore;
  final int endScore;
  final int pointsEarned;
  final int approvedTaskCount;
  final int neglectedOpenTasks;
}

class CycleRetrospective {
  const CycleRetrospective({
    required this.memberStats,
    this.mvpMemberId,
    this.mostImprovedMemberId,
    this.choreDodgerMemberId,
    this.neglectedChoreTitles = const [],
  });

  final List<CycleRetrospectiveMemberStats> memberStats;
  final String? mvpMemberId;
  final String? mostImprovedMemberId;
  final String? choreDodgerMemberId;
  final List<String> neglectedChoreTitles;
}

/// Pure calculator for cycle retrospective highlights.
CycleRetrospective calculateCycleRetrospective({
  required String cycleStartScoresJson,
  required Map<String, int> currentScoresByMemberId,
  required List<Task> cycleTasks,
}) {
  final startScores = HandoverCycleHelpers.scoresMapFromJson(
    cycleStartScoresJson,
  );
  final allMemberIds = {
    ...startScores.keys,
    ...currentScoresByMemberId.keys,
  };

  final stats = <CycleRetrospectiveMemberStats>[];
  for (final memberId in allMemberIds) {
    final start = startScores[memberId] ?? 0;
    final end = currentScoresByMemberId[memberId] ?? start;
    final approved = cycleTasks
        .where(
          (t) =>
              t.status == TaskStatus.approved &&
              t.claimedByMemberIds.contains(memberId),
        )
        .length;
    final neglected = cycleTasks
        .where(
          (t) =>
              t.status == TaskStatus.open &&
              !t.claimedByMemberIds.contains(memberId),
        )
        .length;
    stats.add(
      CycleRetrospectiveMemberStats(
        memberId: memberId,
        startScore: start,
        endScore: end,
        pointsEarned: end - start,
        approvedTaskCount: approved,
        neglectedOpenTasks: neglected,
      ),
    );
  }

  String? mvp;
  var bestEarned = -1;
  for (final s in stats) {
    if (s.pointsEarned > bestEarned) {
      bestEarned = s.pointsEarned;
      mvp = s.memberId;
    }
  }

  String? mostImproved;
  var bestDelta = -1;
  for (final s in stats) {
    if (s.pointsEarned > bestDelta) {
      bestDelta = s.pointsEarned;
      mostImproved = s.memberId;
    }
  }

  String? choreDodger;
  var mostNeglected = -1;
  for (final s in stats) {
    if (s.neglectedOpenTasks > mostNeglected) {
      mostNeglected = s.neglectedOpenTasks;
      choreDodger = s.memberId;
    }
  }

  final neglectedTitles = cycleTasks
      .where((t) => t.status == TaskStatus.open && t.claimedByMemberIds.isEmpty)
      .map((t) => t.title)
      .toList();

  return CycleRetrospective(
    memberStats: stats,
    mvpMemberId: bestEarned > 0 ? mvp : null,
    mostImprovedMemberId: bestDelta > 0 ? mostImproved : null,
    choreDodgerMemberId: mostNeglected > 0 ? choreDodger : null,
    neglectedChoreTitles: neglectedTitles,
  );
}
