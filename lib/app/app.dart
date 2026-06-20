import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumah/app/router.dart';
import 'package:rumah/sync/handover_expiry_watcher.dart';
import 'package:rumah/theme/app_theme.dart';

class RumahApp extends ConsumerWidget {
  const RumahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(handoverExpiryWatcherProvider);

    return MaterialApp.router(
      title: 'rumahkita',
      theme: AppTheme.defaultTheme(context),
      scaffoldMessengerKey: ref.watch(rootScaffoldMessengerKeyProvider),
      routerConfig: router,
    );
  }
}
