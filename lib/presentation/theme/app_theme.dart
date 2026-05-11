// B4.3 STATUS: IMPLEMENTED
// F1.7 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';

/// Production-grade design system for SmartAdmin
/// 
/// Principles:
/// - Strong canvas + sheet model (Starling/Apple Wallet style)
/// - Clear visual hierarchy via distinct blue-grey canvas
/// - White cards as floating sheets
/// - Confident typography and spacing
/// - Material 3 design language
class AppTheme {
  AppTheme._();

  /// Light theme (primary theme)
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      // Canvas background - strong blue-grey (Starling-style)
      surface: Color(0xFFF1F6FB),
      surfaceContainerLowest: Color(0xFFFFFFFF), // Pure white for cards (sheets)
      surfaceContainerLow: Color(0xFFEBF1F7),
      surfaceContainer: Color(0xFFE2E8F0),
      
      // Primary - confident blue
      primary: Color(0xFF1E6FD9),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD9E8FB),
      onPrimaryContainer: Color(0xFF0A3D7A),
      
      // Secondary - muted grey (inactive states)
      secondary: Color(0xFF64748B),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE2E8F0),
      onSecondaryContainer: Color(0xFF334155),
      
      // Error - soft red (not alarming)
      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Outline and borders - subtle grey
      outline: Color(0xFF94A3B8),
      outlineVariant: Color(0xFFE2E8F0),
      
      // Text colors
      onSurface: Color(0xFF0F172A),
      onSurfaceVariant: Color(0xFF64748B),
      
      // Shadow
      shadow: Color(0x0F000000),
      scrim: Color(0x66000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography scale
      textTheme: _textTheme(colorScheme),
      
      // Card styling - white sheets with shadow
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: colorScheme.surfaceContainerLowest, // Pure white
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // AppBar styling - matches canvas
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface, // Canvas color
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
        scrolledUnderElevation: 0,
      ),
      
      // Divider styling
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // Icon styling
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      
      // Chip styling
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Bottom Navigation Bar - anchored white sheet with divider
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedItemColor: colorScheme.primary, // #1E6FD9
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0, // No shadow, using divider instead
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        selectedIconTheme: IconThemeData(
          size: 24,
          color: colorScheme.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 24,
          color: Color(0xFF64748B),
        ),
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: colorScheme.surface, // Canvas color
    );
  }

  /// Lavender light theme — new variant from Figma prototype.
  ///
  /// Swaps the primary blue accent for violet/lavender while keeping
  /// the same canvas + sheet model as the calm-neutral variant.
  static ThemeData lavenderLight() {
    const colorScheme = ColorScheme.light(
      surface: Color(0xFFF5F3FF),           // Lavender-tinted canvas
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFEDE9FE),
      surfaceContainer: Color(0xFFE0D9FC),

      primary: Color(0xFF7C3AED),           // Violet-600
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFEDE9FE),
      onPrimaryContainer: Color(0xFF3B0764),

      secondary: Color(0xFF6D28D9),         // Violet-700 (deeper accent)
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFF3E8FF),
      onSecondaryContainer: Color(0xFF4C1D95),

      tertiary: Color(0xFF9333EA),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFF3E8FF),
      onTertiaryContainer: Color(0xFF581C87),

      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),

      outline: Color(0xFFA78BFA),
      outlineVariant: Color(0xFFDDD6FE),

      onSurface: Color(0xFF1E1B4B),
      onSurfaceVariant: Color(0xFF5B21B6),

      shadow: Color(0x0F000000),
      scrim: Color(0x66000000),
    );

    final base = light();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colorScheme.surfaceContainer,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: colorScheme.primary,
      ),
      textTheme: _textTheme(colorScheme),
    );
  }

  /// Lavender dark theme — new variant (paired with lavenderLight).
  static ThemeData lavenderDark() {
    const colorScheme = ColorScheme.dark(
      surface: Color(0xFF0D0B1E),           // Deep violet-black
      surfaceContainerLowest: Color(0xFF13112A),
      surfaceContainerLow: Color(0xFF1A1738),
      surfaceContainer: Color(0xFF221F45),

      primary: Color(0xFFA78BFA),           // Violet-400 (luminous on dark)
      onPrimary: Color(0xFF150D33),
      primaryContainer: Color(0xFF3B1F7A),
      onPrimaryContainer: Color(0xFFEDE9FE),

      secondary: Color(0xFFC4B5FD),         // Violet-300
      onSecondary: Color(0xFF1E0A47),
      secondaryContainer: Color(0xFF2D1B69),
      onSecondaryContainer: Color(0xFFF3E8FF),

      tertiary: Color(0xFFD8B4FE),
      onTertiary: Color(0xFF2D0A57),
      tertiaryContainer: Color(0xFF3B1164),
      onTertiaryContainer: Color(0xFFF5F3FF),

      error: Color(0xFFFF6B6B),
      onError: Color(0xFF3B0A0A),
      errorContainer: Color(0xFF4A1212),
      onErrorContainer: Color(0xFFFFD9D9),

      outline: Color(0xFF5B21B6),
      outlineVariant: Color(0xFF2D1B69),

      onSurface: Color(0xFFF5F3FF),
      onSurfaceVariant: Color(0xFFC4B5FD),

      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
    );

    final base = dark();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colorScheme.surfaceContainer,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: colorScheme.primary,
      ),
      textTheme: _textTheme(colorScheme),
    );
  }

  /// Dark theme (system/optional)
  ///
  /// Keeps the same canvas + sheet model:
  /// - Deep blue-grey canvas
  /// - Slightly lifted sheet surfaces for cards/nav
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      // Canvas background (deep, calm)
      surface: Color(0xFF0B1220),
      surfaceContainerLowest: Color(0xFF0F1A2B), // Card / sheet
      surfaceContainerLow: Color(0xFF121F33),
      surfaceContainer: Color(0xFF16253B),

      // Primary - luminous blue
      primary: Color(0xFF6AA7FF),
      onPrimary: Color(0xFF07121F),
      primaryContainer: Color(0xFF133B6B),
      onPrimaryContainer: Color(0xFFD9E8FB),

      // Secondary - muted slate
      secondary: Color(0xFF9AA6B2),
      onSecondary: Color(0xFF0B1220),
      secondaryContainer: Color(0xFF24324A),
      onSecondaryContainer: Color(0xFFEAF0F7),

      // Error - softened red
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF3B0A0A),
      errorContainer: Color(0xFF4A1212),
      onErrorContainer: Color(0xFFFFD9D9),

      // Outline and borders
      outline: Color(0xFF3A4B6B),
      outlineVariant: Color(0xFF24324A),

      // Text colors
      onSurface: Color(0xFFEAF0F7),
      onSurfaceVariant: Color(0xFF9AA6B2),

      // Shadow/scrim
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme(colorScheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        selectedIconTheme: IconThemeData(
          size: 24,
          color: colorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  /// Typography scale following Material 3 guidelines
  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles (largest)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.22,
        color: colorScheme.onSurface,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.25,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.29,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: colorScheme.onSurface,
      ),
      
      // Title styles (section headers)
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.27,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        height: 1.50,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      
      // Body styles (main content)
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: colorScheme.onSurfaceVariant,
      ),
      
      // Label styles (buttons, chips)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.33,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
