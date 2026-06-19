import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

export 'package:rumah/services/sync_service.dart'
    show TailscaleMeshService, TailscalePeer;

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
