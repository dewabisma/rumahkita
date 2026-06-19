import 'package:flutter_test/flutter_test.dart';
import 'package:hlc_dart/hlc_dart.dart';
import 'package:rumah/sync/merge_engine.dart';

void main() {
  test('higher HLC wins LWW register', () {
    final low = HybridLogicalClock(l: 10, c: 0);
    final high = HybridLogicalClock(l: 20, c: 0);
    expect(
      LwwRegister.shouldApply(
        incomingHlc: high,
        incomingDeviceId: 'b',
        existingHlcBytes: low.toUint8List(),
        existingDeviceId: 'a',
      ),
      isTrue,
    );
    expect(
      LwwRegister.shouldApply(
        incomingHlc: low,
        incomingDeviceId: 'a',
        existingHlcBytes: high.toUint8List(),
        existingDeviceId: 'b',
      ),
      isFalse,
    );
  });

  test('equal HLC tie-break by device id', () {
    final clock = HybridLogicalClock(l: 10, c: 0);
    expect(
      LwwRegister.shouldApply(
        incomingHlc: clock,
        incomingDeviceId: 'device-z',
        existingHlcBytes: clock.toUint8List(),
        existingDeviceId: 'device-a',
      ),
      isTrue,
    );
  });

  test('missing incumbent HLC accepts incoming', () {
    final clock = HybridLogicalClock(l: 1, c: 0);
    expect(
      LwwRegister.shouldApply(
        incomingHlc: clock,
        incomingDeviceId: 'device-a',
        existingHlcBytes: null,
        existingDeviceId: null,
      ),
      isTrue,
    );
  });

  test('existing HLC with null device id uses empty incumbent', () {
    final incumbent = HybridLogicalClock(l: 10, c: 0);
    final lower = HybridLogicalClock(l: 9, c: 0);
    expect(
      LwwRegister.shouldApply(
        incomingHlc: lower,
        incomingDeviceId: 'device-a',
        existingHlcBytes: incumbent.toUint8List(),
        existingDeviceId: null,
      ),
      isFalse,
    );
  });
}
