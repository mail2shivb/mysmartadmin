import 'package:flutter/material.dart';

/// Semantic color scheme interface
/// 
/// Defines all color roles used throughout the app.
/// Implementations provide specific colors for different themes.
/// 
/// Widgets should reference these semantic roles, never hard-coded colors.
/// 
/// 3-LAYER ARCHITECTURE:
/// 1. appBackground - Full-screen canvas (lowest layer)
/// 2. surface - Section containers (middle layer)
/// 3. card - Content focus (highest layer, most elevated)
abstract class AppColorScheme {
  // Core surfaces (3-layer system)
  Color get appBackground;  // App canvas (custom colors apply here)
  Color get surface;        // Section containers
  Color get card;           // Content cards (most elevated)
  Color get surfaceContainer;

  // Gradient backgrounds (for soft gradient style)
  Color get backgroundGradientStart;
  Color get backgroundGradientEnd;

  // Brand colors
  Color get primary;
  Color get primaryContainer;
  Color get onPrimary;
  Color get secondary;

  // Semantic state colors
  Color get success;
  Color get successLight;
  Color get warning;
  Color get warningLight;
  Color get danger;
  Color get dangerLight;
  Color get info;
  Color get infoLight;

  // Text colors
  Color get textPrimary;
  Color get textSecondary;

  // UI elements
  Color get border;
  Color get divider;

  // Icon system
  Color get iconBackground; // Semantic icon container (tinted with primary)
  
  // Icon badge backgrounds (for domain categories - legacy support)
  Color get iconBackgroundBlue;
  Color get iconBackgroundGreen;
  Color get iconBackgroundOrange;
  Color get iconBackgroundPurple;
  Color get iconBackgroundRed;
  Color get iconBackgroundGrey;

  // Derived colors for Material components
  Color get onSurface;
  Color get onSurfaceVariant;
  Color get onBackground;
  Color get outline;
  
  // Legacy support (backward compatibility - implementations should return appBackground)
  @Deprecated('Use appBackground instead')
  Color get background;
}

