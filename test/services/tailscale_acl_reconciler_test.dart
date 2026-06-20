import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_acl_reconciler.dart';
import 'package:rumah/services/tailscale_api_transport.dart';

void main() {
  group('TailscaleAclReconciler', () {
    late Map<String, dynamic> aclPolicy;
    late Map<String, Map<String, dynamic>> devicesByNodeKey;
  late int postAttempts;

    setUp(() {
      aclPolicy = {
        'acls': [
          {'action': 'accept', 'src': ['*'], 'dst': ['*']},
        ],
      };
      devicesByNodeKey = {
        'node-a': {
          'nodeId': 'dev-a',
          'nodeKey': 'node-a',
          'tags': <String>[],
        },
        'node-b': {
          'nodeId': 'dev-b',
          'nodeKey': 'node-b',
          'tags': ['tag:house-h1'],
        },
        'node-c': {
          'nodeId': 'dev-c',
          'nodeKey': 'node-c',
          'tags': ['tag:house-h1'],
        },
      };
      postAttempts = 0;
    });

    FakeTailscaleApiTransport buildTransport() {
      return FakeTailscaleApiTransport(
        handlers: {
          'GET /tailnet/-/acl': (_, __, {headers, body}) async {
            return TailscaleHttpResponse(
              statusCode: 200,
              headers: {'etag': '"v1"'},
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
            postAttempts++;
            if (postAttempts == 1) {
              return const TailscaleHttpResponse(
                statusCode: 412,
                headers: {},
                body: '{"message":"etag mismatch"}',
              );
            }
            aclPolicy = jsonDecode(body!) as Map<String, dynamic>;
            return TailscaleHttpResponse(
              statusCode: 200,
              headers: {'etag': '"v2"'},
              body: body,
            );
          },
          'GET /tailnet/-/devices': (_, __, {headers, body}) async {
            return TailscaleHttpResponse(
              statusCode: 200,
              headers: {},
              body: jsonEncode({
                'devices': devicesByNodeKey.values.toList(),
              }),
            );
          },
          'GET *': (_, path, {headers, body}) async {
            final deviceId = path.split('/').last.split('?').first;
            final device = devicesByNodeKey.values.firstWhere(
              (d) => d['nodeId'] == deviceId,
            );
            return TailscaleHttpResponse(
              statusCode: 200,
              headers: {},
              body: jsonEncode(device),
            );
          },
          'POST *': (_, path, {headers, body}) async {
            if (path.contains('/tags')) {
              final deviceId = path.split('/')[2];
              final decoded = jsonDecode(body!) as Map<String, dynamic>;
              final tags = (decoded['tags'] as List).cast<String>();
              for (final entry in devicesByNodeKey.entries) {
                if (entry.value['nodeId'] == deviceId) {
                  entry.value['tags'] = tags;
                }
              }
              return const TailscaleHttpResponse(
                statusCode: 200,
                headers: {},
                body: '',
              );
            }
            return const TailscaleHttpResponse(
              statusCode: 200,
              headers: {},
              body: '',
            );
          },
        },
      );
    }

    test('retries once on ETag mismatch', () async {
      final reconciler = TailscaleAclReconciler(transport: buildTransport());
      await reconciler.reconcileHouseAclFragment(
        houseId: 'h1',
        otherHouseFragments: [],
      );
      expect(postAttempts, 2);
    });

    test('assigns and untags devices via API list', () async {
      final transport = buildTransport();
      final reconciler = TailscaleAclReconciler(transport: transport);

      await reconciler.syncHouseTags(
        houseId: 'h1',
        activeMembers: const [
          HouseAclMember(memberId: 'm-a', tailscaleNodeKey: 'node-a'),
        ],
      );

      expect(devicesByNodeKey['node-a']!['tags'], ['tag:house-h1']);
      expect(devicesByNodeKey['node-b']!['tags'], isEmpty);
      expect(devicesByNodeKey['node-c']!['tags'], isEmpty);
    });

    test('reconciles empty tailnet policy', () async {
      var aclPolicy = <String, dynamic>{};
      final transport = FakeTailscaleApiTransport(
        handlers: {
          'GET /tailnet/-/acl': (_, __, {headers, body}) async {
            return TailscaleHttpResponse(
              statusCode: 200,
              headers: {'etag': '"v0"'},
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
        },
      );
      final reconciler = TailscaleAclReconciler(transport: transport);

      await reconciler.reconcileHouseAclFragment(
        houseId: 'h1',
        otherHouseFragments: [],
      );

      expect(aclPolicy['tagOwners'], isNotNull);
      expect(aclPolicy['acls'], isNotEmpty);
    });

    test('refuses malformed ACL without blind POST', () async {
      final transport = FakeTailscaleApiTransport(
        handlers: {
          'GET /tailnet/-/acl': (_, __, {headers, body}) async {
            return const TailscaleHttpResponse(
              statusCode: 200,
              headers: {'etag': '"v1"'},
              body: '{"acls":"broken"}',
            );
          },
        },
      );
      final reconciler = TailscaleAclReconciler(transport: transport);

      expect(
        () => reconciler.reconcileHouseAclFragment(
          houseId: 'h1',
          otherHouseFragments: [],
        ),
        throwsA(isA<TailscaleAclException>()),
      );
    });
  });
}
