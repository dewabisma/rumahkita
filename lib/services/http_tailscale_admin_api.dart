import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_acl_merger.dart';
import 'package:rumah/services/tailscale_acl_reconciler.dart';
import 'package:rumah/services/tailscale_admin_api.dart';
import 'package:rumah/services/tailscale_api_transport.dart';

/// Live Tailscale Admin API client backed by HTTP.
class HttpTailscaleAdminApi implements TailscaleAdminApi {
  HttpTailscaleAdminApi({
    required String apiKey,
    String tailnet = '-',
    TailscaleApiTransport? transport,
  }) : _reconciler = TailscaleAclReconciler(
         transport:
             transport ??
             HttpTailscaleApiTransport(apiKey: apiKey),
         tailnet: tailnet,
       );

  final TailscaleAclReconciler _reconciler;

  @override
  Future<void> invalidateNodeKey({
    required String tailscaleNodeKey,
    required String houseId,
  }) async {
    final deviceId = await resolveDeviceId(tailscaleNodeKey: tailscaleNodeKey);
    await _reconciler.expireDeviceKey(deviceId);
  }

  @override
  Future<void> reconcileHouseAcl({
    required String houseId,
    required List<HouseAclMember> activeMembers,
  }) async {
    final fetched = await _reconciler.fetchAcl();
    final syntax = TailscaleAclBuilder.detectSyntax(fetched.policy);
    final rumahHouseIds = TailscaleAclMerger.rumahHouseIdsInPolicy(
      fetched.policy,
    );
    rumahHouseIds.add(houseId);

    final otherFragments = rumahHouseIds
        .where((id) => id != houseId)
        .map((id) => TailscaleAclBuilder.buildFragment(id, syntax: syntax))
        .toList();

    await _reconciler.reconcileHouseAclFragment(
      houseId: houseId,
      otherHouseFragments: otherFragments,
    );
    await _reconciler.syncHouseTags(
      houseId: houseId,
      activeMembers: activeMembers,
    );
  }

  @override
  Future<String> resolveDeviceId({required String tailscaleNodeKey}) =>
      _reconciler.resolveDeviceId(tailscaleNodeKey: tailscaleNodeKey);

  Future<String?> resolvePlaceholderNodeKey(String storedNodeKey) =>
      _reconciler.resolvePlaceholderNodeKey(storedNodeKey);
}
