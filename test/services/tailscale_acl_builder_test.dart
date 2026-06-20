import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_sync_transport.dart';

void main() {
  group('TailscaleAclBuilder', () {
    test('buildFragment uses sync transport port 5555', () {
      const houseId = 'abc-123';
      final fragment = TailscaleAclBuilder.buildFragment(houseId);
      final tag = TailscaleAclBuilder.houseTag(houseId);

      expect(fragment['tagOwners'], {
        tag: ['autogroup:admin'],
      });

      final acls = fragment['acls'] as List;
      expect(acls, hasLength(6));

      final accept = acls.first as Map<String, dynamic>;
      expect(accept['action'], 'accept');
      expect(accept['ports'], ['tcp:${syncTransportPort}']);

      final denySsh = acls[1] as Map<String, dynamic>;
      expect(denySsh['ports'], ['22']);

      final denyUntagged = acls.last as Map<String, dynamic>;
      expect(denyUntagged['src'], ['*']);
      expect(denyUntagged['dst'], [tag]);
    });
  });
}
