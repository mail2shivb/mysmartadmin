import 'package:flutter/material.dart';

/// Appearance controller - fintech-grade simplicity
/// 
/// Controls ONLY:
/// - Theme Mode (System/Light/Dark)
/// 
/// Designer controls everything else:
/// - Fixed accent color (indigo)
/// - Canvas colors (premium dark/light)
/// - Typography, spacing, components
/// 
/// Follows fintech app patterns (Monzo, Emma)
class AppearanceController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}

/// Fixed design system colors (NOT user-customizable)
/// 
/// Following fintech-grade premium dark design (Monzo/Emma style)
class DesignTokens {
  /// Fixed accent color - Indigo/Violet tone
  /// Used for: buttons, selections, key highlights
  /// NEVER used for: backgrounds, surfaces, cards
  static const accentColor = Color(0xFF8B5CF6); // Premium indigo/violet
  
  /// Accent at 10% opacity for icon containers
  static final accentContainer = accentColor.withValues(alpha: 0.10);
  
  /// Accent at 12% opacity for dark mode icon containers
  static final accentContainerDark = accentColor.withValues(alpha: 0.12);
}

