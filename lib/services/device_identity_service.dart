import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  DeviceIdentityService({
    FlutterSecureStorage? secureStorage,
    Uuid? uuid,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _uuid = uuid ?? const Uuid();

  static const _deviceIdKey = 'rumah_device_id';
  static const _nodeKeyKey = 'rumah_tailscale_node_key';

  final FlutterSecureStorage _secureStorage;
  final Uuid _uuid;

  String? _cachedDeviceId;
  String? _cachedNodeKey;

  Future<String> getOrCreateDeviceId() async {
    _cachedDeviceId ??= await _secureStorage.read(key: _deviceIdKey);
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }
    _cachedDeviceId = _uuid.v4();
    await _secureStorage.write(key: _deviceIdKey, value: _cachedDeviceId);
    return _cachedDeviceId!;
  }

  Future<String> getOrCreateNodeKey() async {
    _cachedNodeKey ??= await _secureStorage.read(key: _nodeKeyKey);
    if (_cachedNodeKey != null) {
      return _cachedNodeKey!;
    }
    _cachedNodeKey = 'node-${_uuid.v4()}';
    await _secureStorage.write(key: _nodeKeyKey, value: _cachedNodeKey);
    return _cachedNodeKey!;
  }

  Future<void> bindTailscaleNode(String nodeKey) async {
    _cachedNodeKey = nodeKey;
    await _secureStorage.write(key: _nodeKeyKey, value: nodeKey);
  }
}

class TailscalePeer {
  const TailscalePeer({
    required this.nodeKey,
    required this.hostName,
    required this.online,
  });

  final String nodeKey;
  final String hostName;
  final bool online;
}

/// Skeleton wrapper isolating tailscale package API churn.
class TailscaleMeshService {
  TailscaleMeshService({required this.stateDirectory});

  final String stateDirectory;
  bool _isUp = false;
  final List<TailscalePeer> _peers = [];

  bool get isUp => _isUp;

  List<TailscalePeer> get peers => List.unmodifiable(_peers);

  Future<void> up({String? authKey}) async {
  // Phase 0 skeleton — real tailscale integration deferred to device testing.
    _isUp = true;
    _peers
      ..clear()
      ..addAll([
        const TailscalePeer(
          nodeKey: 'skeleton-peer',
          hostName: 'skeleton-peer',
          online: true,
        ),
      ]);
  }

  Future<void> down() async {
    _isUp = false;
    _peers.clear();
  }

  void setPeersForTesting(List<TailscalePeer> peers) {
    _peers
      ..clear()
      ..addAll(peers);
  }
}

Future<AppDatabase> openAppDatabase({QueryExecutor? executor}) async {
  if (executor != null) {
    return AppDatabase(executor);
  }
  final dir = await getApplicationDocumentsDirectory();
  final file = p.join(dir.path, 'rumah.sqlite');
  return AppDatabase(
    LazyDatabase(() async => NativeDatabase.createInBackground(File(file))),
  );
}

AppDatabase openMemoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
