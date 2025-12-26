import 'package:flutter/material.dart';

/// Application color palette
/// 
/// DEPRECATED: This class is deprecated in favor of the semantic theme system.
/// Use AppThemeProvider.colorsOf(context) in widgets instead.
/// 
/// Example migration:
///   Before: AppColors.primary
///   After:  AppThemeProvider.colorsOf(context).primary
/// 
/// Kept temporarily for reference during migration.
@Deprecated('Use AppThemeProvider.colorsOf(context) instead')
class AppColors {
  AppColors._();

  // Primary brand color - calm, trustworthy blue
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);

  // Backgrounds - off-white for calm feel
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceContainerLight = Color(0xFFF8F8F8);
  static const Color surfaceContainerDark = Color(0xFF2A2A2A);

  // Semantic colors - subtle, not aggressive
  
  /// Info color - calm blue
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);
  
  /// Success color - gentle green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  
  /// Warning color - soft amber
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFE0B2);
  
  /// Danger color - subtle red (not aggressive)
  static const Color danger = Color(0xFFEF5350);
  static const Color dangerLight = Color(0xFFFFCDD2);

  // Document status (legacy - map to semantic)
  static const Color statusActive = success;
  static const Color statusExpiring = warning;
  static const Color statusExpired = danger;

  // Neutral grays
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Icon background tints (subtle)
  static const Color iconBackgroundBlue = Color(0xFFE3F2FD);
  static const Color iconBackgroundGreen = Color(0xFFE8F5E9);
  static const Color iconBackgroundOrange = Color(0xFFFFF3E0);
  static const Color iconBackgroundPurple = Color(0xFFF3E5F5);
  static const Color iconBackgroundRed = Color(0xFFFFEBEE);
  static const Color iconBackgroundGrey = Color(0xFFF5F5F5);
}

