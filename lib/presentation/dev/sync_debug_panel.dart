import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';
import 'package:rumah/sync/peer_allowlist.dart';
import 'package:uuid/uuid.dart';

class SyncDebugPanel extends ConsumerStatefulWidget {
  const SyncDebugPanel({super.key});

  @override
  ConsumerState<SyncDebugPanel> createState() => _SyncDebugPanelState();
}

class _SyncDebugPanelState extends ConsumerState<SyncDebugPanel> {
  final _uuid = const Uuid();
  String? _houseId;
  String? _memberId;
  String? _joinCredential;
  String? _deviceId;
  int _allowlistSize = 0;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  Future<void> _loadContext() async {
    final db = ref.read(databaseProvider);
    final settings =
        await (db.select(db.localUserSettings)).getSingleOrNull();
    final allowlist = await _computeAllowlistSize();
    if (!mounted) {
      return;
    }
    setState(() {
      _houseId = settings?.activeHouseId;
      _deviceId = settings?.deviceId;
      _allowlistSize = allowlist;
    });
  }

  Future<void> _createHouse() async {
    setState(() => _status = 'Creating house...');
    final memberId = _uuid.v4();
    _memberId = memberId;
    final db = ref.read(databaseProvider);
    final settings = await (db.select(db.localUserSettings)).getSingle();
    final house = await ref.read(houseRepositoryProvider).createHouse(
          displayName: 'Cozy Apartment',
          creatorMemberId: memberId,
        );
    await ref.read(housemateRepositoryProvider).addCreatorHousemate(
          houseId: house.houseId,
          memberId: memberId,
          tailscaleUserId: 'user-${settings.deviceId}',
          tailscaleNodeKey: settings.tailscaleNodeId,
          nickname: 'Creator',
        );
    final credential =
        await ref.read(houseRepositoryProvider).generateJoinCredential(
              house.houseId,
            );
    setState(() {
      _houseId = house.houseId;
      _joinCredential = credential;
      _status = 'House created';
    });
    await _loadContext();
  }

  Future<void> _addAuditEntry() async {
    if (_houseId == null || _memberId == null) {
      setState(() => _status = 'Create a house first');
      return;
    }
    await ref.read(auditLogRepositoryProvider).appendEntry(
          houseId: _houseId!,
          taskId: _uuid.v4(),
          actorMemberId: _memberId!,
          action: 'test',
          justificationNotes: 'Phase 0 vertical slice',
        );
    setState(() => _status = 'Audit entry appended');
  }

  Future<int> _computeAllowlistSize() async {
    if (_houseId == null) {
      return 0;
    }
    final db = ref.read(databaseProvider);
    final housemates = await (db.select(db.housematesSync)
          ..where((t) => t.houseId.equals(_houseId!)))
        .get();
    final settings =
        await (db.select(db.localUserSettings)).getSingleOrNull();
    final allowlist = PeerAllowlist(
      activeMemberNodeKeys: housemates
          .where((m) => m.memberStatus == MemberStatus.active.wireValue)
          .map((m) => m.tailscaleNodeKey)
          .toSet(),
      localNodeKey: settings?.tailscaleNodeId ?? '',
    );
    return allowlist.size;
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncServiceProvider);
    final pending = ref.watch(pendingOpCountProvider).asData?.value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('rumahkita — Dev Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: $_status'),
          const SizedBox(height: 8),
          Text('house_id: ${_houseId ?? '(none)'}'),
          Text('device_id: ${_deviceId ?? '(loading)'}'),
          Text('allowlist size: $_allowlistSize'),
          Text('pending ops: $pending'),
          Text(
            'last merge: ${sync.lastMergeResult?.appliedOpIds.length ?? 0} applied',
          ),
          Text('last error: ${sync.lastError ?? '(none)'}'),
          const SizedBox(height: 8),
          Text('peers: ${sync.connectedPeers.length}'),
          ...sync.connectedPeers.map(
            (p) => Text('  • ${p.hostName} (${p.nodeKey})'),
          ),
          if (_joinCredential != null) ...[
            const SizedBox(height: 8),
            const Text('join_credential:'),
            SelectableText(_joinCredential!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _createHouse,
            child: const Text('Create House'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _addAuditEntry,
            child: const Text('Add Test Audit Entry'),
          ),
        ],
      ),
    );
  }
}
