import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/app.dart';
import 'package:rumah/app/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await createAppState();
  runApp(
    ProviderScope(
      overrides: [appStateProvider.overrideWithValue(appState)],
      child: const RumahApp(),
    ),
  );
}
