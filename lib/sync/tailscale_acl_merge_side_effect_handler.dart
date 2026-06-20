import 'package:drift/drift.dart';
import 'package:rumah/data/local/app_database.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/domain/repositories/local_settings_repository.dart';
import 'package:rumah/services/tailscale_acl_builder.dart';
import 'package:rumah/services/tailscale_admin_api.dart';
import 'package:rumah/sync/merge_side_effect.dart';

/// Reconciles Tailscale ACL tags when a housemate joins, if creator holds key.
class TailscaleAclMergeSideEffectHandler implements MergeSideEffectHandler {
  TailscaleAclMergeSideEffectHandler({
    required AppDatabase db,
    required LocalSettingsRepository localSettings,
    TailscaleAdminApi? tailscaleAdminOverride,
  })  : _db = db,
        _localSettings = localSettings,
        _tailscaleAdminOverride = tailscaleAdminOverride;

  final AppDatabase _db;
  final LocalSettingsRepository _localSettings;
  final TailscaleAdminApi? _tailscaleAdminOverride;

  @override
  Future<void> handle(List<MergeSideEffect> effects) async {
    for (final effect in effects) {
      if (effect is HousemateJoined) {
        await _handleHousemateJoined(effect);
      }
    }
  }

  Future<void> _handleHousemateJoined(HousemateJoined effect) async {
    if (!await _isCreatorWithAdminKey(effect.houseId)) {
      return;
    }
    final tailscaleAdmin =
        _tailscaleAdminOverride ?? await createTailscaleAdminApi(_localSettings);
    final activeMembers = await _loadActiveMembers(effect.houseId);
    await tailscaleAdmin.reconcileHouseAcl(
      houseId: effect.houseId,
      activeMembers: activeMembers,
    );
  }

  Future<bool> _isCreatorWithAdminKey(String houseId) async {
    final adminKey = await _localSettings.getTailscaleAdminApiKey();
    if (adminKey == null || adminKey.isEmpty) {
      return false;
    }
    final house = await (_db.select(_db.houseSync)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    if (house == null) {
      return false;
    }
    final localNodeKey = await _localSettings.getTailscaleNodeKey();
    final creator = await (_db.select(_db.housematesSync)
          ..where((t) => t.memberId.equals(house.creatorMemberId)))
        .getSingleOrNull();
    return creator?.tailscaleNodeKey == localNodeKey;
  }

  Future<List<HouseAclMember>> _loadActiveMembers(String houseId) async {
    final rows = await (_db.select(_db.housematesSync)
          ..where(
            (t) =>
                t.houseId.equals(houseId) &
                t.memberStatus.equals(MemberStatus.active.wireValue),
          ))
        .get();
    return rows
        .map(
          (r) => HouseAclMember(
            memberId: r.memberId,
            tailscaleNodeKey: r.tailscaleNodeKey,
          ),
        )
        .toList();
  }
}
