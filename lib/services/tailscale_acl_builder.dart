import 'package:rumah/services/tailscale_sync_transport.dart';

/// Whether the tailnet policy uses grants or legacy ACL rules.
enum TailscalePolicySyntax { grants, acls }

/// Builds the per-house policy fragment for Tailscale network isolation.
class TailscaleAclBuilder {
  TailscaleAclBuilder._();

  static String houseTag(String houseId) => 'tag:house-$houseId';

  /// Picks grants when the tailnet already uses grants and has no ACL section.
  static TailscalePolicySyntax detectSyntax(Map<String, dynamic> policy) {
    final grants = policy['grants'];
    final acls = policy['acls'];
    if (grants is List &&
        grants.isNotEmpty &&
        (acls == null || (acls is List && acls.isEmpty))) {
      return TailscalePolicySyntax.grants;
    }
    return TailscalePolicySyntax.acls;
  }

  /// Returns a JSON-serializable fragment: `tagOwners` plus house rules.
  static Map<String, dynamic> buildFragment(
    String houseId, {
    required TailscalePolicySyntax syntax,
  }) {
    final tag = houseTag(houseId);
    final syncPort = syncTransportPort.toString();
    final tagOwners = {
      tag: ['autogroup:admin'],
    };

    switch (syntax) {
      case TailscalePolicySyntax.grants:
        return {
          'tagOwners': tagOwners,
          'grants': [
            {
              'src': [tag],
              'dst': [tag],
              'ip': ['tcp:$syncPort'],
            },
          ],
        };
      case TailscalePolicySyntax.acls:
        return {
          'tagOwners': tagOwners,
          'acls': [
            {
              'action': 'accept',
              'src': [tag],
              'dst': ['$tag:$syncPort'],
            },
          ],
        };
    }
  }
}

/// Active housemate referenced during ACL reconciliation.
class HouseAclMember {
  const HouseAclMember({
    required this.memberId,
    required this.tailscaleNodeKey,
  });

  final String memberId;
  final String tailscaleNodeKey;
}
