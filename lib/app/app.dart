import 'package:flutter/material.dart';
import 'router.dart';
import '../core/ui/theme.dart';

/// Root application widget for LedgerAI
/// 
/// Principles enforced:
/// - Offline-first (no network dependencies)
/// - Privacy-first (no analytics)
/// - Material 3 design
class LedgerApp extends StatelessWidget {
  const LedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LedgerAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
