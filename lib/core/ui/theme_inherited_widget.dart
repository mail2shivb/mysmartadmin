import 'package:flutter/material.dart';
import 'app_color_scheme.dart';

/// Provides access to semantic colors throughout widget tree
/// 
/// FINTECH-GRADE THEME SYSTEM:
/// - Designer-controlled colors (Monzo/Emma style)
/// - Fixed accent color (indigo)
/// - User controls ONLY theme mode (System/Light/Dark)
class AppThemeProvider extends InheritedWidget {
  final AppColorScheme colors;

  const AppThemeProvider({
    super.key,
    required this.colors,
    required super.child,
  });

  /// Get semantic colors from context
  static AppColorScheme colorsOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppThemeProvider>();
    assert(provider != null, 'No AppThemeProvider found in context');
    return provider!.colors;
  }

  @override
  bool updateShouldNotify(AppThemeProvider oldWidget) {
    return colors != oldWidget.colors;
  }
}
