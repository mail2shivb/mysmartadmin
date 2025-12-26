import 'package:flutter/material.dart';
import 'app_color_scheme.dart';
import 'app_theme_type.dart';
import 'themes/calm_neutral_light_theme.dart';
import 'themes/calm_neutral_dark_theme.dart';
import 'tokens.dart';

/// Complete theme package (semantic colors + Material theme)
/// 
/// Bridges our semantic color system with Material 3 ThemeData.
/// Fintech-grade with fixed designer-controlled colors (Monzo/Emma style).
class AppThemeData {
  final AppColorScheme colors;
  final ThemeData materialTheme;
  final AppThemeType type;

  const AppThemeData({
    required this.colors,
    required this.materialTheme,
    required this.type,
  });

  /// Light theme (fintech-grade)
  factory AppThemeData.light() {
    const colors = CalmNeutralLightTheme();
    return AppThemeData(
      colors: colors,
      materialTheme: _buildMaterialTheme(colors, Brightness.light),
      type: AppThemeType.calmLight,
    );
  }

  /// Dark theme (fintech-grade with gradient)
  factory AppThemeData.dark() {
    const colors = CalmNeutralDarkTheme();
    return AppThemeData(
      colors: colors,
      materialTheme: _buildMaterialTheme(colors, Brightness.dark),
      type: AppThemeType.calmDark,
    );
  }

  /// Build Material ThemeData from semantic colors
  /// 
  /// Accent color is FIXED (designer-controlled) - comes from theme colors.primary
  static ThemeData _buildMaterialTheme(
    AppColorScheme colors,
    Brightness brightness,
  ) {
    // Use fixed accent from theme (no user customization)
    final primary = colors.primary;
    final primaryContainer = colors.primaryContainer;
    
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary, // Fixed indigo accent
      onPrimary: colors.onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: colors.onSurface,
      secondary: colors.secondary,
      onSecondary: brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.onSurface,
      onSurfaceVariant: colors.onSurfaceVariant,
      outline: colors.outline,
      shadow: Colors.black.withValues(alpha: 0.1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.appBackground, // Use appBackground for canvas
      
      // Card theme - floating cards with premium feel
      cardTheme: CardThemeData(
        elevation: 0, // Flat for modern aesthetic
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Fintech-grade radius (14-18px)
          side: BorderSide(
            color: colors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        color: colors.surface, // Cards use surface color (float above background)
        margin: EdgeInsets.zero,
      ),

      // AppBar theme - clean with proper contrast
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colors.appBackground, // Use appBackground for consistency
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),

      // NavigationBar - uses surface container with elevation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primaryContainer,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),

      // FAB theme - elevated with shadow
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // ListTile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colors.divider,
        space: AppSpacing.xl,
        thickness: 1,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card, // Use card color for inputs (elevated)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
