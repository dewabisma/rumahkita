import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_admin_api.dart';

/// No-op Tailscale admin API for development and tests.
class StubTailscaleAdminApi implements TailscaleAdminApi {
  StubTailscaleAdminApi();

  final List<({String nodeKey, String houseId})> invalidations = [];
  final List<({
    String houseId,
    List<HouseAclMember> activeMembers,
  })> reconciliations = [];
  final Map<String, String> deviceIdsByNodeKey = {};

  @override
  Future<void> invalidateNodeKey({
    required String tailscaleNodeKey,
    required String houseId,
  }) async {
    invalidations.add((nodeKey: tailscaleNodeKey, houseId: houseId));
  }

  @override
  Future<void> reconcileHouseAcl({
    required String houseId,
    required List<HouseAclMember> activeMembers,
  }) async {
    reconciliations.add((houseId: houseId, activeMembers: activeMembers));
  }

  @override
  Future<String> resolveDeviceId({required String tailscaleNodeKey}) async {
    final id = deviceIdsByNodeKey[tailscaleNodeKey];
    if (id == null) {
      throw StateError('No device id for node key $tailscaleNodeKey');
    }
    return id;
  }
}
