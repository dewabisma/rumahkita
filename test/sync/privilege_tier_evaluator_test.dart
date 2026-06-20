import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/domain/entities/privilege_template.dart';
import 'package:rumah/sync/privilege_tier_evaluator.dart';

void main() {
  final templates = PrivilegeTemplate.defaultsMap();

  group('isPrivilegeActive', () {
    test('reward active when score >= threshold', () {
      final parking = templates['parking']!;
      expect(isPrivilegeActive(template: parking, score: 80), isTrue);
      expect(isPrivilegeActive(template: parking, score: 79), isFalse);
    });

    test('penalty active when score < threshold', () {
      final penalty = templates['slot_restriction']!;
      expect(isPrivilegeActive(template: penalty, score: 29), isTrue);
      expect(isPrivilegeActive(template: penalty, score: 30), isFalse);
    });

    test('disabled template is never active', () {
      final disabled = templates['parking']!.copyWith(enabled: false);
      expect(isPrivilegeActive(template: disabled, score: 100), isFalse);
    });
  });

  group('detectCrossings', () {
    test('reward unlock crossing', () {
      final crossings = detectCrossings(
        templates: templates,
        oldScore: 79,
        newScore: 80,
      );
      expect(
        crossings.any(
          (c) => c.template.id == 'parking' && c.direction == 'unlocked',
        ),
        isTrue,
      );
    });

    test('reward lock crossing', () {
      final crossings = detectCrossings(
        templates: templates,
        oldScore: 80,
        newScore: 79,
      );
      expect(
        crossings.any(
          (c) => c.template.id == 'parking' && c.direction == 'locked',
        ),
        isTrue,
      );
    });

    test('penalty applied crossing', () {
      final crossings = detectCrossings(
        templates: templates,
        oldScore: 30,
        newScore: 29,
      );
      expect(
        crossings.any(
          (c) =>
              c.template.id == 'slot_restriction' &&
              c.direction == 'penalty_applied',
        ),
        isTrue,
      );
    });

    test('penalty cleared crossing', () {
      final crossings = detectCrossings(
        templates: templates,
        oldScore: 29,
        newScore: 30,
      );
      expect(
        crossings.any(
          (c) =>
              c.template.id == 'slot_restriction' &&
              c.direction == 'penalty_cleared',
        ),
        isTrue,
      );
    });

    test('no crossings when score unchanged', () {
      expect(
        detectCrossings(templates: templates, oldScore: 50, newScore: 50),
        isEmpty,
      );
    });

    test('no crossings when threshold not crossed', () {
      final crossings = detectCrossings(
        templates: templates,
        oldScore: 50,
        newScore: 55,
      );
      expect(crossings, isEmpty);
    });

    test('disabled templates excluded from crossings', () {
      final custom = {
        'parking': templates['parking']!.copyWith(enabled: false),
      };
      expect(
        detectCrossings(templates: custom, oldScore: 79, newScore: 80),
        isEmpty,
      );
    });
  });

  group('evaluateAll', () {
    test('returns enabled templates with correct active state', () {
      final states = evaluateAll(templates: templates, score: 85);
      final parking = states.firstWhere((s) => s.templateId == 'parking');
      final chorePass = states.firstWhere((s) => s.templateId == 'chore_pass');
      expect(parking.isActive, isTrue);
      expect(chorePass.isActive, isFalse);
    });
  });
}
