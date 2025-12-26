import 'package:flutter/material.dart';
import '../app_color_scheme.dart';
import '../appearance_controller.dart';

/// Premium Dark Theme - Fintech-grade (Monzo/Emma style)
/// 
/// Deep, rich dark background with floating elevated surfaces.
/// NOT pure black - uses charcoal with subtle depth.
/// Optimized for premium feel and extended use.
class CalmNeutralDarkTheme implements AppColorScheme {
  const CalmNeutralDarkTheme();

  // Core surfaces - fintech-grade dark (DESIGNER-CONTROLLED, FIXED)
  @override
  Color get appBackground => const Color(0xFF0F1117); // Deep base (Monzo-style)

  @override
  Color get surface => const Color(0xFF1C1F2E); // Elevated cards (float above background)

  @override
  Color get card => const Color(0xFF1C1F2E); // Same as surface for consistency

  @override
  Color get surfaceContainer => const Color(0xFF23263A); // Alternative elevation

  // Gradient backgrounds - subtle vertical depth
  @override
  Color get backgroundGradientStart => const Color(0xFF0F1117); // Top

  @override
  Color get backgroundGradientEnd => const Color(0xFF141625); // Bottom (slightly lighter)

  // Brand colors - fixed indigo accent
  @override
  Color get primary => DesignTokens.accentColor; // #8B5CF6 indigo/violet

  @override
  Color get primaryContainer => const Color(0xFF6D28D9); // Darker variant

  @override
  Color get onPrimary => const Color(0xFFFFFFFF); // White on accent

  @override
  Color get secondary => const Color(0xFFA8B3CF); // Muted lavender grey

  // Semantic state colors - adjusted for dark premium feel
  @override
  Color get success => const Color(0xFF10B981); // Emerald green

  @override
  Color get successLight => const Color(0xFF065F46); // Dark emerald

  @override
  Color get warning => const Color(0xFFF59E0B); // Amber

  @override
  Color get warningLight => const Color(0xFF92400E); // Dark amber

  @override
  Color get danger => const Color(0xFFEF4444); // Red

  @override
  Color get dangerLight => const Color(0xFF991B1B); // Dark red

  @override
  Color get info => const Color(0xFF3B82F6); // Blue

  @override
  Color get infoLight => const Color(0xFF1E40AF); // Dark blue

  // Text colors - near-white, not pure white (fintech calm)
  @override
  Color get textPrimary => const Color(0xFFF1F5F9); // Soft white

  @override
  Color get textSecondary => const Color(0xFFA8B3CF); // Muted lavender grey

  // UI elements - subtle on premium dark
  @override
  Color get border => const Color(0xFF2A2F45); // Soft border

  @override
  Color get divider => const Color(0xFF2A2F45);

  // Icon system - fixed accent-based containers
  @override
  Color get iconBackground => DesignTokens.accentContainerDark; // Accent @ 12%

  // Icon badge backgrounds - accent-tinted for consistency
  @override
  Color get iconBackgroundBlue => const Color(0xFF1E3A8A);

  @override
  Color get iconBackgroundGreen => const Color(0xFF065F46);

  @override
  Color get iconBackgroundOrange => const Color(0xFF9A3412);

  @override
  Color get iconBackgroundPurple => const Color(0xFF6B21A8);

  @override
  Color get iconBackgroundRed => const Color(0xFF991B1B);

  @override
  Color get iconBackgroundGrey => const Color(0xFF374151);

  // Derived colors for Material components
  @override
  Color get onSurface => textPrimary;

  @override
  Color get onSurfaceVariant => textSecondary;

  @override
  Color get onBackground => textPrimary;

  @override
  Color get outline => border;
  
  // Legacy support (backward compatibility)
  @Deprecated('Use appBackground instead')
  @override
  Color get background => appBackground;
}
