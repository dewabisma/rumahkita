import 'dart:convert';

import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_acl_merger.dart';
import 'package:rumah/services/tailscale_api_transport.dart';

/// Orchestrates Tailscale ACL GET/merge/POST and device tag synchronization.
class TailscaleAclReconciler {
  TailscaleAclReconciler({
    required TailscaleApiTransport transport,
    this.tailnet = '-',
  }) : _transport = transport;

  final TailscaleApiTransport _transport;
  final String tailnet;

  Future<({Map<String, dynamic> policy, String? etag})> fetchAcl() async {
    final response = await _transport.get('/tailnet/$tailnet/acl');
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        'GET ACL failed (${response.statusCode}): ${response.body}',
      );
    }
    final decoded = _decodePolicyBody(response.body);
    final etag = response.headers['etag'];
    return (policy: decoded, etag: etag);
  }

  static Map<String, dynamic> _decodePolicyBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      throw TailscaleAclException('GET ACL returned non-object JSON');
    }
    return decoded;
  }

  Future<void> validatePolicy(Map<String, dynamic> policy) async {
    final body = jsonEncode(policy);
    final response = await _transport.post(
      '/tailnet/$tailnet/acl/validate',
      body: body,
    );
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        _formatApiFailure('ACL validation failed', response),
      );
    }
    if (response.body.isEmpty) {
      return;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] as String?;
      if (message != null && message.isNotEmpty) {
        throw TailscaleAclException('ACL validation failed: $message');
      }
    }
  }

  Future<void> postAcl({
    required Map<String, dynamic> policy,
    String? ifMatch,
  }) async {
    await validatePolicy(policy);

    final body = jsonEncode(policy);
    final response = await _transport.post(
      '/tailnet/$tailnet/acl',
      headers: ifMatch != null ? {'If-Match': _normalizeEtag(ifMatch)} : null,
      body: body,
    );
    if (response.statusCode == 412) {
      throw TailscaleAclEtagMismatchException(response.body);
    }
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        _formatApiFailure('POST ACL failed', response),
      );
    }
  }

  static String _normalizeEtag(String etag) {
    final trimmed = etag.trim();
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed;
    }
    return '"$trimmed"';
  }

  static String _formatApiFailure(String prefix, TailscaleHttpResponse response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) {
        return '$prefix (${response.statusCode}): ${decoded['message']}';
      }
    } on Object {
      // Fall through to raw body.
    }
    return '$prefix (${response.statusCode}): ${response.body}';
  }

  /// Merges the house fragment for [houseId] into the tailnet ACL and POSTs it.
  ///
  /// Retries once on HTTP 412 (ETag mismatch).
  Future<void> reconcileHouseAclFragment({
    required String houseId,
    required List<Map<String, dynamic>> otherHouseFragments,
  }) async {
    var attempt = 0;
    while (true) {
      final fetched = await fetchAcl();
      if (!TailscaleAclMerger.isWellFormedPolicy(fetched.policy)) {
        throw TailscaleAclException(
          'Refusing to POST: current ACL policy is malformed',
        );
      }

      final syntax = TailscaleAclBuilder.detectSyntax(fetched.policy);
      final fragment = TailscaleAclBuilder.buildFragment(
        houseId,
        syntax: syntax,
      );
      final allFragments = [...otherHouseFragments, fragment];

      final merged = TailscaleAclMerger.merge(
        currentPolicy: fetched.policy,
        houseFragments: allFragments,
      );

      try {
        await postAcl(
          policy: merged,
          ifMatch: fetched.etag,
        );
        return;
      } on TailscaleAclEtagMismatchException {
        if (attempt >= 1) {
          rethrow;
        }
        attempt++;
      }
    }
  }

  Future<List<TailscaleDevice>> listDevices() async {
    final response = await _transport.get('/tailnet/$tailnet/devices');
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        'List devices failed (${response.statusCode}): ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final devices = (decoded['devices'] as List?) ?? [];
    return devices
        .map((d) => TailscaleDevice.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<String?> tryResolveDeviceId({required String tailscaleNodeKey}) async {
    final devices = await listDevices();
    for (final device in devices) {
      if (device.nodeKey == tailscaleNodeKey) {
        return device.deviceId;
      }
    }
    return null;
  }

  /// Resolves the tailnet node key for this device when the app still holds a
  /// local placeholder (`node-<uuid>`) instead of the real `nodekey:…` value.
  Future<String?> resolvePlaceholderNodeKey(String storedNodeKey) async {
    final devices = await listDevices();
    if (devices.isEmpty) {
      return null;
    }

    for (final device in devices) {
      if (device.nodeKey == storedNodeKey) {
        return storedNodeKey;
      }
    }

    if (!_looksLikePlaceholderNodeKey(storedNodeKey)) {
      return null;
    }

    if (devices.length == 1) {
      return devices.first.nodeKey;
    }

    return null;
  }

  static bool _looksLikePlaceholderNodeKey(String nodeKey) {
    return nodeKey.startsWith('node-') && !nodeKey.startsWith('nodekey:');
  }

  Future<String> resolveDeviceId({required String tailscaleNodeKey}) async {
    final deviceId = await tryResolveDeviceId(tailscaleNodeKey: tailscaleNodeKey);
    if (deviceId != null) {
      return deviceId;
    }
    throw TailscaleAclException(
      'No device found for node key $tailscaleNodeKey',
    );
  }

  Future<List<String>> getDeviceTags(String deviceId) async {
    final response = await _transport.get('/device/$deviceId?fields=all');
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        'Get device failed (${response.statusCode}): ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final tags = decoded['tags'];
    if (tags is List) {
      return tags.cast<String>();
    }
    return [];
  }

  Future<void> setDeviceTags(String deviceId, List<String> tags) async {
    final response = await _transport.post(
      '/device/$deviceId/tags',
      body: jsonEncode({'tags': tags}),
    );
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        'Set device tags failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> syncHouseTags({
    required String houseId,
    required List<HouseAclMember> activeMembers,
  }) async {
    final houseTag = TailscaleAclBuilder.houseTag(houseId);
    final desiredNodeKeys =
        activeMembers.map((m) => m.tailscaleNodeKey).toSet();

    for (final member in activeMembers) {
      final deviceId = await tryResolveDeviceId(
        tailscaleNodeKey: member.tailscaleNodeKey,
      );
      if (deviceId == null) {
        continue;
      }
      final currentTags = await getDeviceTags(deviceId);
      if (!currentTags.contains(houseTag)) {
        await setDeviceTags(deviceId, [...currentTags, houseTag]);
      }
    }

    final devices = await listDevices();
    for (final device in devices) {
      if (!device.tags.contains(houseTag)) {
        continue;
      }
      if (desiredNodeKeys.contains(device.nodeKey)) {
        continue;
      }
      final updatedTags = device.tags.where((t) => t != houseTag).toList();
      await setDeviceTags(device.deviceId, updatedTags);
    }
  }

  Future<void> expireDeviceKey(String deviceId) async {
    final response = await _transport.post('/device/$deviceId/expire');
    if (response.statusCode != 200) {
      throw TailscaleAclException(
        'Expire device key failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}

class TailscaleDevice {
  const TailscaleDevice({
    required this.deviceId,
    required this.nodeKey,
    required this.tags,
    this.hostName,
  });

  final String deviceId;
  final String nodeKey;
  final List<String> tags;
  final String? hostName;

  factory TailscaleDevice.fromJson(Map<String, dynamic> json) {
    return TailscaleDevice(
      deviceId: (json['nodeId'] as String?) ?? (json['id'] as String? ?? ''),
      nodeKey: json['nodeKey'] as String? ?? '',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      hostName: (json['hostname'] as String?) ?? (json['name'] as String?),
    );
  }
}

class TailscaleAclException implements Exception {
  TailscaleAclException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TailscaleAclEtagMismatchException extends TailscaleAclException {
  TailscaleAclEtagMismatchException(super.message);
}
