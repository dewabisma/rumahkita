abstract class LocalSettingsRepository {
  Stream<String?> watchActiveHouseId();

  Future<String?> getActiveHouseId();

  Future<void> setActiveHouseId(String? houseId);

  Future<String?> getBootstrapHostNodeKey();

  Future<void> setBootstrapHostNodeKey(String? nodeKey);

  Future<String?> getTailscaleAuthKey();

  Future<void> setTailscaleAuthKey(String? authKey);

  Future<String?> getTailscaleAdminApiKey();

  Future<void> setTailscaleAdminApiKey(String? apiKey);

  Future<String> getDeviceId();

  Future<String> getTailscaleNodeKey();
}
