import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';

class DriftLocalSettingsRepository implements LocalSettingsRepository {
  DriftLocalSettingsRepository({
    required AppDatabase db,
    FlutterSecureStorage? secureStorage,
  })  : _db = db,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _bootstrapHostKey = 'rumah_bootstrap_host_node_key';
  static const _tailscaleAuthKey = 'rumah_tailscale_auth_key';

  final AppDatabase _db;
  final FlutterSecureStorage _secureStorage;

  @override
  Stream<String?> watchActiveHouseId() {
    return (_db.select(_db.localUserSettings)).watchSingleOrNull().map(
          (row) => row?.activeHouseId,
        );
  }

  @override
  Future<String?> getActiveHouseId() async {
    final row = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    return row?.activeHouseId;
  }

  @override
  Future<void> setActiveHouseId(String? houseId) async {
    final row = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    if (row == null) {
      return;
    }
    await (_db.update(_db.localUserSettings)
          ..where((t) => t.deviceId.equals(row.deviceId)))
        .write(LocalUserSettingsCompanion(activeHouseId: Value(houseId)));
  }

  @override
  Future<String?> getBootstrapHostNodeKey() =>
      _secureStorage.read(key: _bootstrapHostKey);

  @override
  Future<void> setBootstrapHostNodeKey(String? nodeKey) async {
    if (nodeKey == null) {
      await _secureStorage.delete(key: _bootstrapHostKey);
    } else {
      await _secureStorage.write(key: _bootstrapHostKey, value: nodeKey);
    }
  }

  @override
  Future<String?> getTailscaleAuthKey() =>
      _secureStorage.read(key: _tailscaleAuthKey);

  @override
  Future<void> setTailscaleAuthKey(String? authKey) async {
    if (authKey == null) {
      await _secureStorage.delete(key: _tailscaleAuthKey);
    } else {
      await _secureStorage.write(key: _tailscaleAuthKey, value: authKey);
    }
  }

  @override
  Future<String> getDeviceId() async {
    final row = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    return row?.deviceId ?? '';
  }

  @override
  Future<String> getTailscaleNodeKey() async {
    final row = await (_db.select(_db.localUserSettings)).getSingleOrNull();
    return row?.tailscaleNodeId ?? '';
  }
}
