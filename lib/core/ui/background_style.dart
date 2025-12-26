import 'package:flutter/material.dart';

/// Available background styles
/// 
/// Defines how the app canvas is rendered.
/// All styles maintain a neutral, premium aesthetic.
/// Accent colors influence these at 5-8% opacity max.
enum BackgroundStyle {
  /// Solid neutral canvas with optional subtle accent tint
  solid,
  
  /// Very subtle gradient with optional accent influence
  gradient;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case BackgroundStyle.solid:
        return 'Solid';
      case BackgroundStyle.gradient:
        return 'Soft Gradient';
    }
  }

  /// Short description
  String get description {
    switch (this) {
      case BackgroundStyle.solid:
        return 'Clean, calm canvas';
      case BackgroundStyle.gradient:
        return 'Gentle depth and dimension';
    }
  }

  /// Icon for selector
  IconData get icon {
    switch (this) {
      case BackgroundStyle.solid:
        return Icons.crop_square;
      case BackgroundStyle.gradient:
        return Icons.gradient;
    }
  }
}

