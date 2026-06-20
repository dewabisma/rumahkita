import 'package:rumah/services/tailscale_sync_transport.dart';

/// Builds the per-house ACL policy fragment for Tailscale network isolation.
class TailscaleAclBuilder {
  TailscaleAclBuilder._();

  static String houseTag(String houseId) => 'tag:house-$houseId';

  /// Returns a JSON-serializable fragment: `tagOwners` + `acls` for one house.
  static Map<String, dynamic> buildFragment(String houseId) {
    final tag = houseTag(houseId);
    final syncPort = syncTransportPort.toString();
    return {
      'tagOwners': {
        tag: ['autogroup:admin'],
      },
      'acls': [
        {
          'action': 'accept',
          'src': [tag],
          'dst': [tag],
          'ports': ['tcp:$syncPort'],
        },
        {
          'action': 'deny',
          'src': [tag],
          'dst': [tag],
          'proto': 'tcp',
          'ports': ['22'],
        },
        {
          'action': 'deny',
          'src': [tag],
          'dst': [tag],
          'proto': 'tcp',
          'ports': ['80', '443'],
        },
        {
          'action': 'deny',
          'src': [tag],
          'dst': [tag],
          'proto': 'icmp',
        },
        {
          'action': 'deny',
          'src': [tag],
          'dst': [tag],
          'proto': 'tcp',
          'ports': ['5900'],
        },
        {
          'action': 'deny',
          'src': ['*'],
          'dst': [tag],
        },
      ],
    };
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
