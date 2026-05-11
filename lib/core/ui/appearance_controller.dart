import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'colour_variant.dart';

/// Appearance controller — controls theme mode and colour variant.
///
/// Persists both selections to [SharedPreferences] so the user's choice
/// survives app restarts.
class AppearanceController extends ChangeNotifier {
  static const _kThemeMode = 'appearance_theme_mode';
  static const _kColourVariant = 'appearance_colour_variant';

  ThemeMode _themeMode = ThemeMode.system;
  AppColourVariant _colourVariant = AppColourVariant.calmNeutral;

  AppearanceController();

  /// Call once after construction to restore persisted preferences.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_kThemeMode);
    if (modeIndex != null && modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }
    final variantIndex = prefs.getInt(_kColourVariant);
    if (variantIndex != null && variantIndex < AppColourVariant.values.length) {
      _colourVariant = AppColourVariant.values[variantIndex];
    }
    notifyListeners();
  }

  /// Current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Current colour variant.
  AppColourVariant get colourVariant => _colourVariant;

  /// Set theme mode and persist.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kThemeMode, mode.index);
    }
  }

  /// Set colour variant and persist.
  Future<void> setColourVariant(AppColourVariant variant) async {
    if (_colourVariant != variant) {
      _colourVariant = variant;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kColourVariant, variant.index);
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

