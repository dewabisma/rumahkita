import 'package:rumah/domain/repositories/local_settings_repository.dart';
import 'package:rumah/services/device_identity_service.dart';
import 'package:rumah/services/http_tailscale_admin_api.dart';
import 'package:rumah/services/tailscale_admin_api.dart';

Future<void> bindTailscaleNodeKey({
  required LocalSettingsRepository localSettings,
  required DeviceIdentityService deviceIdentity,
  required String nodeKey,
}) async {
  await localSettings.setTailscaleNodeKey(nodeKey);
  await deviceIdentity.bindTailscaleNode(nodeKey);
}

/// Replaces a local placeholder node key with the real tailnet value when known.
Future<void> resolveAndBindTailscaleNodeKey({
  required LocalSettingsRepository localSettings,
  required DeviceIdentityService deviceIdentity,
  required TailscaleAdminApi adminApi,
}) async {
  if (adminApi is! HttpTailscaleAdminApi) {
    return;
  }

  final storedNodeKey = await localSettings.getTailscaleNodeKey();
  final resolved = await adminApi.resolvePlaceholderNodeKey(storedNodeKey);
  if (resolved == null || resolved == storedNodeKey) {
    return;
  }

  await bindTailscaleNodeKey(
    localSettings: localSettings,
    deviceIdentity: deviceIdentity,
    nodeKey: resolved,
  );

  final bootstrapHost = await localSettings.getBootstrapHostNodeKey();
  if (bootstrapHost == storedNodeKey) {
    await localSettings.setBootstrapHostNodeKey(resolved);
  }
}
