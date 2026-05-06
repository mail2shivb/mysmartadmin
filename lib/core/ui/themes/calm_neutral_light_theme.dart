import 'package:flutter/material.dart';
import '../app_color_scheme.dart';
import '../appearance_controller.dart';

/// Premium Light Theme - Fintech-grade clean aesthetic
/// 
/// Soft off-white background with floating white cards.
/// NOT pure white - uses fintech neutral grey.
/// Optimized for daylight readability and professional feel.
class CalmNeutralLightTheme implements AppColorScheme {
  const CalmNeutralLightTheme();

  // Core surfaces - fintech neutral (DESIGNER-CONTROLLED, FIXED)
  @override
  Color get appBackground => const Color(0xFFF6F7FB); // Fintech neutral (NOT white)

  @override
  Color get surface => const Color(0xFFFAFBFC); // Very subtle off-white (layer separation)

  @override
  Color get card => const Color(0xFFFFFFFF); // Pure white cards (most elevated)

  @override
  Color get surfaceContainer => const Color(0xFFF0F2F8); // Darker alternative container

  // Gradient backgrounds - very subtle (rarely used in light mode)
  @override
  Color get backgroundGradientStart => const Color(0xFFFAFBFD); // Lighter

  @override
  Color get backgroundGradientEnd => const Color(0xFFF6F7FB); // Slightly darker

  // Brand colors - fixed indigo accent
  @override
  Color get primary => DesignTokens.accentColor; // #8B5CF6 indigo/violet

  @override
  Color get primaryContainer => const Color(0xFFEDE9FE); // Very light purple

  @override
  Color get onPrimary => const Color(0xFFFFFFFF); // White on accent

  @override
  Color get secondary => const Color(0xFF64748B); // Slate grey

  // Semantic state colors - optimized for light backgrounds
  @override
  Color get success => const Color(0xFF10B981); // Emerald green

  @override
  Color get successLight => const Color(0xFFD1FAE5); // Light emerald

  @override
  Color get warning => const Color(0xFFF59E0B); // Amber

  @override
  Color get warningLight => const Color(0xFFFEF3C7); // Light amber

  @override
  Color get danger => const Color(0xFFEF4444); // Red

  @override
  Color get dangerLight => const Color(0xFFFEE2E2); // Light red

  @override
  Color get info => const Color(0xFF3B82F6); // Blue

  @override
  Color get infoLight => const Color(0xFFDBEAFE); // Light blue

  // Text colors - strong contrast for readability
  @override
  Color get textPrimary => const Color(0xFF0F172A); // Near-black slate

  @override
  Color get textSecondary => const Color(0xFF64748B); // Slate grey

  // UI elements - subtle on light
  @override
  Color get border => const Color(0xFFE2E8F0); // Soft border

  @override
  Color get divider => const Color(0xFFE2E8F0);

  // Icon system - fixed accent-based containers
  @override
  Color get iconBackground => DesignTokens.accentContainer; // Accent @ 10%

  // Icon badge backgrounds - accent-tinted for consistency
  @override
  Color get iconBackgroundBlue => const Color(0xFFDBEAFE);

  @override
  Color get iconBackgroundGreen => const Color(0xFFD1FAE5);

  @override
  Color get iconBackgroundOrange => const Color(0xFFFED7AA);

  @override
  Color get iconBackgroundPurple => const Color(0xFFEDE9FE);

  @override
  Color get iconBackgroundRed => const Color(0xFFFEE2E2);

  @override
  Color get iconBackgroundGrey => const Color(0xFFF1F5F9);

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

