// B4.3 STATUS: IMPLEMENTED
// F1 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../core/ui/appearance_controller.dart';
import '../core/ui/app_theme_data.dart';
import '../core/ui/theme_inherited_widget.dart';
import '../presentation/theme/app_theme.dart';
import 'router.dart';

/// Root application widget - fintech-grade
/// 
/// Manages:
/// - Theme mode (System/Light/Dark)
/// - Fixed premium design system (Monzo/Emma style)
/// - System brightness detection
/// - Navigation
class LedgerApp extends StatefulWidget {
  const LedgerApp({super.key});

  @override
  State<LedgerApp> createState() => _LedgerAppState();
}

class _LedgerAppState extends State<LedgerApp> with WidgetsBindingObserver {
  late final AppearanceController _appearanceController;
  Brightness? _systemBrightness;

  @override
  void initState() {
    super.initState();
    _appearanceController = AppearanceController();
    _systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appearanceController.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_systemBrightness != brightness) {
      setState(() {
        _systemBrightness = brightness;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appearanceController,
      builder: (context, _) {
        // Determine which theme to use based on theme mode and system brightness
        final isDark = _appearanceController.themeMode == ThemeMode.dark ||
            (_appearanceController.themeMode == ThemeMode.system &&
                (_systemBrightness ?? Brightness.light) == Brightness.dark);
        
        final currentTheme = isDark
            ? AppThemeData.dark()
            : AppThemeData.light();
        
        return MaterialApp.router(
          title: 'LedgerAI',
          debugShowCheckedModeBanner: false,
          // F1 Design System: Production-grade calm UI
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _appearanceController.themeMode,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            // Provide both appearance controller and theme colors to widget tree
            return AppearanceProvider(
              controller: _appearanceController,
              child: AppThemeProvider(
                colors: currentTheme.colors,
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}

/// Provides [AppearanceController] to widget tree (fintech-grade)
class AppearanceProvider extends InheritedNotifier<AppearanceController> {
  const AppearanceProvider({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppearanceController of(BuildContext context) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<AppearanceProvider>()
        ?.notifier;
    assert(controller != null, 'No AppearanceProvider found in context');
    return controller!;
  }
}
