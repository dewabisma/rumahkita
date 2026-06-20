import 'package:rumah/services/tailscale_admin_api.dart';

/// No-op Tailscale admin API for development and tests.
class StubTailscaleAdminApi implements TailscaleAdminApi {
  StubTailscaleAdminApi();

  final List<({String nodeKey, String houseId})> invalidations = [];

  @override
  Future<void> invalidateNodeKey({
    required String tailscaleNodeKey,
    required String houseId,
  }) async {
    invalidations.add((nodeKey: tailscaleNodeKey, houseId: houseId));
  }
}
