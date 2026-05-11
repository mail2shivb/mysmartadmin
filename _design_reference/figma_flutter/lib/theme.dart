import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFFBF9FF);
  static const sheet = Color(0xFFFFFFFF);
  static const lavSurface = Color(0xFFF7F2FF);
  static const lavPale = Color(0xFFF3ECFF);
  static const lavBorder = Color(0xFFE3D6FF);
  static const action = Color(0xFF8B5CF6);
  static const primary = Color(0xFF9D4EDD);
  static const royal = Color(0xFF7C3AED);
  static const deep = Color(0xFF5B21B6);
  static const plum = Color(0xFF5B1B73);
  static const text = Color(0xFF1E1233);
  static const text2 = Color(0xFF6B5A7A);
  static const textMuted = Color(0xFF9485A6);
  static const divider = Color(0xFFECE3F8);
  static const success = Color(0xFF2FBF71);
  static const warn = Color(0xFFF5A623);
  static const urgent = Color(0xFFEF5B5B);
  static const info = Color(0xFF3B82F6);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B1B73), Color(0xFF7B2CBF), Color(0xFF9D4EDD)],
  );

  static const purpleButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)],
  );
}

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.royal,
      surface: AppColors.sheet,
    ),
    textTheme: textTheme,
    splashFactory: InkRipple.splashFactory,
  );
}
