/// Admin API for Tailscale node lifecycle (ACL deferred to Phase 7b).
abstract class TailscaleAdminApi {
  Future<void> invalidateNodeKey({
    required String tailscaleNodeKey,
    required String houseId,
  });
}
