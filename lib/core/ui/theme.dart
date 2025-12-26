import 'package:flutter/material.dart';
import 'app_theme_data.dart';

/// Application theme configuration
/// 
/// DEPRECATED: Use AppThemeData.light() and AppThemeData.dark() directly.
/// This class maintained for backward compatibility.
/// 
/// Prefer using AppThemeProvider.colorsOf(context) for colors in widgets.
class AppTheme {
  AppTheme._();

  /// Light theme - uses CalmLightColorScheme
  static ThemeData get lightTheme => AppThemeData.light().materialTheme;

  /// Dark theme - uses CalmDarkColorScheme
  static ThemeData get darkTheme => AppThemeData.dark().materialTheme;
}

