import 'package:flutter/material.dart';
import 'package:rumah/presentation/dev/sync_debug_panel.dart';
import 'package:rumah/theme/app_theme.dart';

class RumahApp extends StatelessWidget {
  const RumahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rumahkita',
      theme: AppTheme.defaultTheme(context),
      home: const SyncDebugPanel(),
    );
  }
}
