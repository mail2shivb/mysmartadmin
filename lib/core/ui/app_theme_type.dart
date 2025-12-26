import 'package:flutter/material.dart';

/// Theme type enum - fintech-grade (designer-controlled)
/// 
/// User ONLY controls theme mode (System/Light/Dark)
/// Designer controls all colors and styles
enum AppThemeType {
  system(
    displayName: 'System',
    description: 'Follow device settings',
    icon: Icons.brightness_auto,
    brightness: null, // Adapts to system
  ),
  calmLight(
    displayName: 'Light',
    description: 'Fintech neutral light',
    icon: Icons.light_mode,
    brightness: Brightness.light,
  ),
  calmDark(
    displayName: 'Dark',
    description: 'Premium dark (Monzo/Emma style)',
    icon: Icons.dark_mode,
    brightness: Brightness.dark,
  );

  final String displayName;
  final String description;
  final IconData icon;
  final Brightness? brightness; // null = system adaptive

  const AppThemeType({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.brightness,
  });
}
