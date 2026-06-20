import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/data/repositories/drift_local_settings_repository.dart';
import 'package:rumah/data/repositories/secure_key_value_store.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/sync/hlc.dart';

void main() {
  test('admin API key round-trips via secure storage', () async {
    final db = openMemoryDatabase();
    final hlc = HlcService(deviceId: 'dev-1');
    await db
        .into(db.localUserSettings)
        .insert(
          LocalUserSettingsCompanion.insert(
            deviceId: 'dev-1',
            createdAtHlc: hlc.toBytes(hlc.now()),
          ),
        );

    final storage = InMemorySecureKeyValueStore();
    final repo = DriftLocalSettingsRepository(db: db, secureStorage: storage);

    expect(await repo.getTailscaleAdminApiKey(), isNull);
    await repo.setTailscaleAdminApiKey('tskey-api-roundtrip');
    expect(await repo.getTailscaleAdminApiKey(), 'tskey-api-roundtrip');
    await repo.setTailscaleAdminApiKey(null);
    expect(await repo.getTailscaleAdminApiKey(), isNull);
  });
}
