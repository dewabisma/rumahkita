import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/services/http_tailscale_admin_api.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_api_transport.dart';

void main() {
  test('HttpTailscaleAdminApi reconcile merges ACL and syncs tags', () async {
    var aclPolicy = <String, dynamic>{
      'acls': [
        {'action': 'accept', 'src': ['*'], 'dst': ['*']},
      ],
    };
    final devices = <String, Map<String, dynamic>>{
      'node-1': {
        'nodeId': 'd1',
        'nodeKey': 'node-1',
        'tags': <String>[],
      },
    };

    final transport = FakeTailscaleApiTransport(
      handlers: {
        'GET /tailnet/-/acl': (_, __, {headers, body}) async {
          return TailscaleHttpResponse(
            statusCode: 200,
            headers: {'etag': '"e1"'},
            body: jsonEncode(aclPolicy),
          );
        },
        'POST /tailnet/-/acl/validate': (_, __, {headers, body}) async {
          return const TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: '',
          );
        },
        'POST /tailnet/-/acl': (_, __, {headers, body}) async {
          aclPolicy = jsonDecode(body!) as Map<String, dynamic>;
          return TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: body,
          );
        },
        'GET /tailnet/-/devices': (_, __, {headers, body}) async {
          return TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: jsonEncode({'devices': devices.values.toList()}),
          );
        },
        'GET *': (_, path, {headers, body}) async {
          final id = path.split('/')[2].split('?').first;
          final device = devices.values.firstWhere((d) => d['nodeId'] == id);
          return TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: jsonEncode(device),
          );
        },
        'POST *': (_, path, {headers, body}) async {
          if (path.contains('/tags')) {
            final id = path.split('/')[2];
            final tags = (jsonDecode(body!)['tags'] as List).cast<String>();
            devices.values.firstWhere((d) => d['nodeId'] == id)['tags'] = tags;
          }
          return const TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: '',
          );
        },
      },
    );

    final api = HttpTailscaleAdminApi(
      apiKey: 'tskey-api-test',
      transport: transport,
    );

    await api.reconcileHouseAcl(
      houseId: 'house-1',
      activeMembers: const [
        HouseAclMember(memberId: 'm1', tailscaleNodeKey: 'node-1'),
      ],
    );

    final tag = TailscaleAclBuilder.houseTag('house-1');
    final tagOwners = aclPolicy['tagOwners'] as Map<String, dynamic>;
    expect(tagOwners[tag], ['autogroup:admin']);
    expect(devices['node-1']!['tags'], [tag]);
    expect(transport.requests.any((r) => r.path.contains('/acl')), isTrue);
  });

  test('invalidateNodeKey expires device', () async {
    var expired = false;
    final transport = FakeTailscaleApiTransport(
      handlers: {
        'GET /tailnet/-/devices': (_, __, {headers, body}) async {
          return TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: jsonEncode({
              'devices': [
                {'nodeId': 'd9', 'nodeKey': 'node-9', 'tags': []},
              ],
            }),
          );
        },
        'POST *': (_, path, {headers, body}) async {
          if (path.contains('/expire')) {
            expired = true;
          }
          return const TailscaleHttpResponse(
            statusCode: 200,
            headers: {},
            body: '',
          );
        },
      },
    );

    final api = HttpTailscaleAdminApi(
      apiKey: 'tskey-api-test',
      transport: transport,
    );
    await api.invalidateNodeKey(tailscaleNodeKey: 'node-9', houseId: 'h');
    expect(expired, isTrue);
  });
}
