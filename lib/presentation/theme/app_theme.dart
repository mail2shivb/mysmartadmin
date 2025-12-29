// F1.5 STATUS: IMPLEMENTED

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
      
      // Bottom Navigation Bar - white sheet
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest, // Pure white
        selectedItemColor: colorScheme.primary, // Confident blue
        unselectedItemColor: colorScheme.secondary, // Muted grey
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: colorScheme.surface, // Canvas color
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
