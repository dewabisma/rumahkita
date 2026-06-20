import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_acl_merger.dart';

void main() {
  group('TailscaleAclMerger', () {
    test('normalizes empty policy before merge', () {
      const houseId = 'house-a';
      final fragment = TailscaleAclBuilder.buildFragment(
        houseId,
        syntax: TailscalePolicySyntax.acls,
      );
      final merged = TailscaleAclMerger.merge(
        currentPolicy: {},
        houseFragments: [fragment],
      );

      final acls = merged['acls'] as List;
      expect(acls.length, greaterThan(1));
      expect(acls.last['src'], ['*']);
    });

    test('isWellFormedPolicy accepts empty policy after normalization', () {
      expect(TailscaleAclMerger.isWellFormedPolicy({}), isTrue);
    });

    test('prepends rumah acls and preserves non-rumah sections', () {
      const houseA = 'house-a';
      const houseB = 'house-b';
      final fragmentA = TailscaleAclBuilder.buildFragment(
        houseA,
        syntax: TailscalePolicySyntax.acls,
      );
      final fragmentB = TailscaleAclBuilder.buildFragment(
        houseB,
        syntax: TailscalePolicySyntax.acls,
      );

      final current = {
        'groups': {'admins': ['alice@example.com']},
        'tagOwners': {
          'tag:house-old': ['autogroup:admin'],
          'tag:custom': ['alice@example.com'],
        },
        'acls': [
          {
            'action': 'accept',
            'src': ['tag:house-old'],
            'dst': ['*'],
          },
          {
            'action': 'accept',
            'src': ['*'],
            'dst': ['*'],
          },
        ],
      };

      final merged = TailscaleAclMerger.merge(
        currentPolicy: current,
        houseFragments: [fragmentA, fragmentB],
      );

      expect(merged['groups'], current['groups']);
      final tagOwners = merged['tagOwners'] as Map<String, dynamic>;
      expect(tagOwners.containsKey('tag:house-old'), isFalse);
      expect(tagOwners['tag:custom'], ['alice@example.com']);
      expect(tagOwners[TailscaleAclBuilder.houseTag(houseA)], isNotNull);
      expect(tagOwners[TailscaleAclBuilder.houseTag(houseB)], isNotNull);

      final acls = merged['acls'] as List;
      expect(acls.first['src'], [TailscaleAclBuilder.houseTag(houseA)]);
      expect(acls.last['src'], ['*']);
      expect(acls.last['dst'], ['*']);
    });

    test('rumah deny rules precede wildcard accept', () {
      const houseId = 'precedence-house';
      final fragment = TailscaleAclBuilder.buildFragment(
        houseId,
        syntax: TailscalePolicySyntax.acls,
      );
      final merged = TailscaleAclMerger.merge(
        currentPolicy: {
          'acls': [
            {'action': 'accept', 'src': ['*'], 'dst': ['*']},
          ],
        },
        houseFragments: [fragment],
      );

      expect(
        TailscaleAclMerger.rumahRulesPrecedeWildcardAccept(
          mergedPolicy: merged,
          houseId: houseId,
        ),
        isTrue,
      );
    });

    test('merges grants for grants-based tailnets', () {
      const houseId = 'house-a';
      final fragment = TailscaleAclBuilder.buildFragment(
        houseId,
        syntax: TailscalePolicySyntax.grants,
      );
      final merged = TailscaleAclMerger.merge(
        currentPolicy: {
          'grants': [
            {'src': ['*'], 'dst': ['*'], 'ip': ['*']},
          ],
        },
        houseFragments: [fragment],
      );

      final grants = merged['grants'] as List;
      expect(grants.first['src'], [TailscaleAclBuilder.houseTag(houseId)]);
      expect(grants.last['src'], ['*']);
      expect(merged.containsKey('acls'), isFalse);
    });

    test('rejects malformed policy', () {
      expect(
        TailscaleAclMerger.isWellFormedPolicy({'acls': 'not-a-list'}),
        isFalse,
      );
      expect(
        TailscaleAclMerger.isWellFormedPolicy({'tagOwners': []}),
        isFalse,
      );
      expect(
        TailscaleAclMerger.isWellFormedPolicy({'acls': []}),
        isTrue,
      );
    });
  });
}
