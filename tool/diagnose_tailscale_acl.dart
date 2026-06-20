// ignore_for_file: avoid_print
//
// Local Tailscale ACL diagnostic. Loads keys from .env or environment variables.
//
// Usage:
//   dart run tool/diagnose_tailscale_acl.dart
//
// Prints status codes and error messages only — not your keys or full policy.

import 'dart:convert';
import 'dart:io';

import 'package:rumah/services/http_tailscale_admin_api.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_acl_merger.dart';
import 'package:rumah/services/tailscale_acl_reconciler.dart';
import 'package:rumah/services/tailscale_api_transport.dart';

Future<void> main() async {
  final apiKey = _loadEnv('TAILSCALE_API_KEY');
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln(
      'Set TAILSCALE_API_KEY in .env or the environment, then re-run.',
    );
    exitCode = 1;
    return;
  }

  final transport = HttpTailscaleApiTransport(apiKey: apiKey);
  final reconciler = TailscaleAclReconciler(transport: transport);
  const houseId = '00000000-0000-4000-8000-diagnostic0000';

  try {
    print('1. GET /tailnet/-/acl');
    final fetched = await reconciler.fetchAcl();
    final policy = fetched.policy;
    print('   status: ok');
    print('   etag: ${fetched.etag ?? '(none)'}');
    print('   policy keys: ${policy.keys.join(', ')}');
    print(
      '   acls: ${policy['acls'] is List ? (policy['acls'] as List).length : 'missing'}',
    );
    if (policy['tests'] is List) {
      print('   tests: ${(policy['tests'] as List).length}');
    }

    print('2. Merge rumah house fragment');
    final syntax = TailscaleAclBuilder.detectSyntax(policy);
    print('   policy syntax: $syntax');
    final fragment = TailscaleAclBuilder.buildFragment(houseId, syntax: syntax);
    final merged = TailscaleAclMerger.merge(
      currentPolicy: policy,
      houseFragments: [fragment],
    );
    if (syntax == TailscalePolicySyntax.grants) {
      print('   merged grants: ${(merged['grants'] as List).length}');
    } else {
      print('   merged acls: ${(merged['acls'] as List).length}');
    }

    print('3. POST /tailnet/-/acl/validate');
    await reconciler.validatePolicy(merged);
    print('   status: ok');

    print('4. List devices (for node-key binding)');
    final devices = await reconciler.listDevices();
    print('   device count: ${devices.length}');
    for (final device in devices) {
      final keyPreview = device.nodeKey.length > 20
          ? '${device.nodeKey.substring(0, 20)}…'
          : device.nodeKey;
      print('   - ${device.hostName ?? '(no hostname)'} key=$keyPreview');
    }

    print('5. Dry-run POST skipped (validate passed).');
    print('   To apply for real, create a house in the app.');
  } on TailscaleAclException catch (e) {
    stderr.writeln('FAILED: $e');
    exitCode = 1;
  } finally {
    transport.close();
  }
}

String? _loadEnv(String name) {
  final fromEnv = Platform.environment[name];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }

  final envFile = File('.env');
  if (!envFile.existsSync()) {
    return null;
  }

  for (final line in envFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    final idx = trimmed.indexOf('=');
    if (idx <= 0) {
      continue;
    }
    final key = trimmed.substring(0, idx).trim();
    if (key == name) {
      return trimmed.substring(idx + 1).trim();
    }
  }
  return null;
}
