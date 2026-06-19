import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/app.dart';
import 'package:rumah/app/providers.dart';
import 'package:rumah/services/device_identity_service.dart';

void main() {
  testWidgets('Dev sync panel loads', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final db = openMemoryDatabase();
    final appState = await createAppState(
      testDatabase: db,
      startSync: false,
      testDeviceId: 'test-device',
      testNodeKey: 'test-node',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStateProvider.overrideWithValue(appState)],
        child: const RumahApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('rumahkita — Dev Sync'), findsOneWidget);
    expect(find.text('Create House'), findsOneWidget);
  });
}
