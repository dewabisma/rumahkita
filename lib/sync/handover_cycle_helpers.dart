import 'dart:convert';
import 'dart:typed_data';

import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/domain/enums/cycle_status.dart';
import 'package:rumah/domain/enums/handover_step.dart';
import 'package:rumah/domain/enums/task_status.dart';
import 'package:rumah/sync/hlc.dart';

/// Helpers for handover cycle merge guards and activation timing.
class HandoverCycleHelpers {
  HandoverCycleHelpers._();

  static const defaultCycleDurationDays = 7;
  static const millisecondsPerDay = 24 * 60 * 60 * 1000;

  static bool isHandoverCycle(String statusWire) =>
      statusWire == CycleStatus.handover.wireValue;

  static bool isLiveCycle(String statusWire) =>
      statusWire == CycleStatus.active.wireValue ||
      statusWire == CycleStatus.handover.wireValue;

  static bool isCloseoutStep(String? stepWire) =>
      stepWire == null || stepWire == HandoverStep.closeout.wireValue;

  static bool allowsTaskApproveOnHandover(String? stepWire) =>
      isCloseoutStep(stepWire);

  static bool isTaskApproveScoreEvent(String? reasonRef) =>
      reasonRef != null && reasonRef.startsWith('task_approve:');

  static Uint8List computeEndsAtHlc({
    required Uint8List startedAtHlc,
    required int cycleDurationDays,
  }) {
    final started = HlcService.fromBytes(startedAtHlc);
    final endsPhysical =
        started.l + cycleDurationDays * millisecondsPerDay;
    final endsHlc = HybridLogicalClock(l: endsPhysical, c: started.c);
    return endsHlc.toUint8List();
  }

  static bool isOpHlcBeforeEndsAt({
    required String opHlcBase64,
    required List<int>? endsAtHlcBytes,
  }) {
    if (endsAtHlcBytes == null || endsAtHlcBytes.isEmpty) {
      return false;
    }
    final opHlc = HlcService.fromBytes(
      Uint8List.fromList(base64Decode(opHlcBase64)),
    );
    final endsHlc = HlcService.fromBytes(Uint8List.fromList(endsAtHlcBytes));
    return opHlc.compareTo(endsHlc) < 0;
  }

  static bool hasEnded({
    required List<int>? endsAtHlcBytes,
    required HybridLogicalClock nowHlc,
  }) {
    if (endsAtHlcBytes == null || endsAtHlcBytes.isEmpty) {
      return false;
    }
    final endsHlc = HlcService.fromBytes(Uint8List.fromList(endsAtHlcBytes));
    return nowHlc.compareTo(endsHlc) >= 0;
  }

  static Map<String, int> scoresMapFromJson(String json) {
    if (json.isEmpty || json == '{}') {
      return {};
    }
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );
  }

  static String scoresMapToJson(Map<String, int> scores) => jsonEncode(scores);

  static bool cycleHasPendingReviewTasks({
    required String cycleId,
    required Iterable<({String cycleId, String status})> tasks,
  }) {
    return tasks.any(
      (task) =>
          task.cycleId == cycleId &&
          task.status == TaskStatus.pendingReview.wireValue,
    );
  }
}
