import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';

void main() {
  group('TailscaleAclBuilder', () {
    test('buildFragment grants mode uses tcp port in ip field', () {
      const houseId = 'abc-123';
      final fragment = TailscaleAclBuilder.buildFragment(
        houseId,
        syntax: TailscalePolicySyntax.grants,
      );
      final tag = TailscaleAclBuilder.houseTag(houseId);

      expect(fragment['tagOwners'], {
        tag: ['autogroup:admin'],
      });

      final grants = fragment['grants'] as List;
      expect(grants, hasLength(1));

      final grant = grants.first as Map<String, dynamic>;
      expect(grant['src'], [tag]);
      expect(grant['dst'], [tag]);
      expect(grant['ip'], ['tcp:${syncTransportPort}']);
    });

    test('buildFragment acls mode uses port in dst', () {
      const houseId = 'abc-123';
      final fragment = TailscaleAclBuilder.buildFragment(
        houseId,
        syntax: TailscalePolicySyntax.acls,
      );
      final tag = TailscaleAclBuilder.houseTag(houseId);

      final acls = fragment['acls'] as List;
      expect(acls, hasLength(1));

      final accept = acls.first as Map<String, dynamic>;
      expect(accept['action'], 'accept');
      expect(accept['dst'], ['tag:house-abc-123:${syncTransportPort}']);
      expect(accept.containsKey('ports'), isFalse);
    });

    test('detectSyntax prefers grants when grants exist without acls', () {
      expect(
        TailscaleAclBuilder.detectSyntax({
          'grants': [
            {'src': ['*'], 'dst': ['*'], 'ip': ['*']},
          ],
        }),
        TailscalePolicySyntax.grants,
      );
      expect(
        TailscaleAclBuilder.detectSyntax({
          'grants': [],
          'acls': [
            {'action': 'accept', 'src': ['*'], 'dst': ['*']},
          ],
        }),
        TailscalePolicySyntax.acls,
      );
    });
  });
}
