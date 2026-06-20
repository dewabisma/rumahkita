import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/app.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/app/router.dart';
import 'package:rumah/sync/handover_expiry_watcher.dart';
import 'package:rumah/services/device_identity_service.dart';

HandoverExpiryWatcher _noopHandoverExpiryWatcher(Ref ref) {
  final watcher = HandoverExpiryWatcher(ref: ref);
  ref.onDispose(watcher.dispose);
  return watcher;
}

void main() {
  testWidgets('Welcome screen loads', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final db = openMemoryDatabase();
    final appState = await createAppState(
      testDatabase: db,
      startSync: false,
      testDeviceId: 'test-device',
      testNodeKey: 'test-node',
    );

    final container = ProviderContainer(
      overrides: [
        appStateProvider.overrideWithValue(appState),
        handoverExpiryWatcherProvider.overrideWith(_noopHandoverExpiryWatcher),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RumahApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Start a house'), findsOneWidget);
    expect(find.text('Join a house'), findsOneWidget);
  });

  testWidgets('Dev sync panel loads', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final db = openMemoryDatabase();
    final appState = await createAppState(
      testDatabase: db,
      startSync: false,
      testDeviceId: 'test-device',
      testNodeKey: 'test-node',
    );

    final container = ProviderContainer(
      overrides: [
        appStateProvider.overrideWithValue(appState),
        handoverExpiryWatcherProvider.overrideWith(_noopHandoverExpiryWatcher),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RumahApp(),
      ),
    );
    await tester.pump();

    container.read(routerProvider).go('/dev/sync');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('rumahkita — Dev Sync'), findsOneWidget);
    expect(find.text('Create House'), findsOneWidget);
  });
}
