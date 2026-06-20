import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/http_tailscale_admin_api.dart';
import 'package:rumah/services/stub_tailscale_admin_api.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';

/// Admin API for Tailscale node lifecycle and per-house ACL isolation.
abstract class TailscaleAdminApi {
  Future<void> invalidateNodeKey({
    required String tailscaleNodeKey,
    required String houseId,
  });

  Future<void> reconcileHouseAcl({
    required String houseId,
    required List<HouseAclMember> activeMembers,
  });

  Future<String> resolveDeviceId({required String tailscaleNodeKey});
}

/// Binds [HttpTailscaleAdminApi] when an admin key is stored; stub otherwise.
Future<TailscaleAdminApi> createTailscaleAdminApi(
  LocalSettingsRepository localSettings,
) async {
  final key = await localSettings.getTailscaleAdminApiKey();
  if (key != null && key.isNotEmpty) {
    return HttpTailscaleAdminApi(apiKey: key);
  }
  return StubTailscaleAdminApi();
}
