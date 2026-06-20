import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_acl_merger.dart';

void main() {
  group('TailscaleAclMerger', () {
    test('prepends rumah acls and preserves non-rumah sections', () {
      const houseA = 'house-a';
      const houseB = 'house-b';
      final fragmentA = TailscaleAclBuilder.buildFragment(houseA);
      final fragmentB = TailscaleAclBuilder.buildFragment(houseB);

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
      final fragment = TailscaleAclBuilder.buildFragment(houseId);
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
