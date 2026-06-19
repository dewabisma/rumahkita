import 'package:flutter_test/flutter_test.dart';
import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/sync/hlc.dart';

void main() {
  test('HLC increments on local events', () {
    final service = HlcService(deviceId: 'device-a');
    final first = service.now();
    final second = service.now();
    expect(second.compareTo(first) > 0, isTrue);
  });

  test('tie-break by device_id when HLC equal', () {
    final clock = HybridLogicalClock(l: 100, c: 0);
    final cmp = HlcService.compare(
      clock,
      clock,
      originDeviceIdA: 'device-b',
      originDeviceIdB: 'device-a',
    );
    expect(cmp > 0, isTrue);
  });

  test('concurrent op ordering is deterministic', () {
    final a = HlcService(deviceId: 'a');
    final b = HlcService(deviceId: 'b');
    final aClock = a.now();
    final received = b.receive(a.toBytes(aClock));
    expect(received.compareTo(aClock) >= 0, isTrue);
  });
}
