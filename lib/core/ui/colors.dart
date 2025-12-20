import 'package:flutter/material.dart';

/// Application color palette
/// 
/// Design principles:
/// - Calm, trustworthy colors
/// - No aggressive finance-shaming colors
/// - Accessible contrast ratios
class AppColors {
  AppColors._();

  // Primary brand color - calm, trustworthy blue
  static const Color primary = Color(0xFF1976D2);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  // Semantic colors for document status
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusExpiring = Color(0xFFFF9800);
  static const Color statusExpired = Color(0xFFE53935);

  // Neutral grays
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

