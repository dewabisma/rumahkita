import 'package:rumah/domain/entities/privilege_state.dart';
import 'package:rumah/domain/entities/privilege_template.dart';

/// Whether [template] is active for [score]. Disabled templates are never active.
bool isPrivilegeActive({
  required PrivilegeTemplate template,
  required int score,
}) {
  if (!template.enabled) {
    return false;
  }
  if (template.isPenalty) {
    return score < template.unlockThreshold;
  }
  return score >= template.unlockThreshold;
}

/// Evaluates all enabled templates for [score].
List<PrivilegeState> evaluateAll({
  required Map<String, PrivilegeTemplate> templates,
  required int score,
}) {
  return templates.values
      .where((t) => t.enabled)
      .map(
        (t) => PrivilegeState(
          templateId: t.id,
          name: t.name,
          isActive: isPrivilegeActive(template: t, score: score),
          isPenalty: t.isPenalty,
        ),
      )
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}

/// A threshold crossing detected between [oldScore] and [newScore].
class PrivilegeCrossing {
  const PrivilegeCrossing({
    required this.template,
    required this.direction,
    required this.score,
  });

  final PrivilegeTemplate template;
  final String direction;
  final int score;
}

/// Detects privilege threshold crossings. Disabled templates are excluded.
List<PrivilegeCrossing> detectCrossings({
  required Map<String, PrivilegeTemplate> templates,
  required int oldScore,
  required int newScore,
}) {
  if (oldScore == newScore) {
    return const [];
  }

  final crossings = <PrivilegeCrossing>[];
  for (final template in templates.values) {
    if (!template.enabled) {
      continue;
    }
    final threshold = template.unlockThreshold;
    if (template.isPenalty) {
      if (oldScore >= threshold && newScore < threshold) {
        crossings.add(
          PrivilegeCrossing(
            template: template,
            direction: 'penalty_applied',
            score: newScore,
          ),
        );
      } else if (oldScore < threshold && newScore >= threshold) {
        crossings.add(
          PrivilegeCrossing(
            template: template,
            direction: 'penalty_cleared',
            score: newScore,
          ),
        );
      }
    } else {
      if (oldScore < threshold && newScore >= threshold) {
        crossings.add(
          PrivilegeCrossing(
            template: template,
            direction: 'unlocked',
            score: newScore,
          ),
        );
      } else if (oldScore >= threshold && newScore < threshold) {
        crossings.add(
          PrivilegeCrossing(
            template: template,
            direction: 'locked',
            score: newScore,
          ),
        );
      }
    }
  }
  return crossings;
}
