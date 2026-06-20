import 'dart:typed_data';

import 'package:hlc_dart/hlc_dart.dart';

/// Thin wrapper over [hlc_dart] for deterministic ordering and serialization.
class HlcService {
  HlcService({required String deviceId})
    : _deviceId = deviceId,
      _clock = HybridLogicalClock.initialize();

  final String _deviceId;
  HybridLogicalClock _clock;

  String get deviceId => _deviceId;

  HybridLogicalClock get clock => _clock.copy();

  HybridLogicalClock now() {
    final physical = DateTime.now().millisecondsSinceEpoch;
    _clock = _clock.nextTimestamp(physical);
    return _clock.copy();
  }

  HybridLogicalClock receive(Uint8List remoteBytes) {
    final remote = HybridLogicalClock.fromUint8List(remoteBytes);
    final physical = DateTime.now().millisecondsSinceEpoch;
    _clock = _clock.merge(physical, remote);
    return _clock.copy();
  }

  Uint8List toBytes(HybridLogicalClock hlc) => hlc.toUint8List();

  Uint8List bytesFromClock() => _clock.toUint8List();

  static HybridLogicalClock fromBytes(Uint8List bytes) =>
      HybridLogicalClock.fromUint8List(bytes);

  /// Compare two HLCs; tie-break by [originDeviceId] lexicographically.
  static int compare(
    HybridLogicalClock a,
    HybridLogicalClock b, {
    required String originDeviceIdA,
    required String originDeviceIdB,
  }) {
    final cmp = a.compareTo(b);
    if (cmp != 0) {
      return cmp;
    }
    return originDeviceIdA.compareTo(originDeviceIdB);
  }

  static bool isNewer(
    HybridLogicalClock candidate,
    String candidateDeviceId,
    HybridLogicalClock incumbent,
    String incumbentDeviceId,
  ) {
    return compare(
          candidate,
          incumbent,
          originDeviceIdA: candidateDeviceId,
          originDeviceIdB: incumbentDeviceId,
        ) >
        0;
  }
}
