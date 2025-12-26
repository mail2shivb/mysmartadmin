import 'package:flutter/material.dart';
import 'background_style.dart';

/// Predefined accent colors available for selection
/// 
/// These colors are used as SUBTLE accents (5-8% opacity overlays).
/// They influence icon backgrounds and selection indicators.
/// The base canvas always remains neutral.
class BackgroundColors {
  static const List<Color> palette = [
    Color(0xFF2196F3), // Blue (refined from light blue)
    Color(0xFF1976D2), // Deep Blue (refined)
    Color(0xFF4CAF50), // Green (refined)
    Color(0xFF388E3C), // Deep Green (refined)
    Color(0xFFFF9800), // Orange (refined)
    Color(0xFFF57C00), // Deep Orange (refined)
    Color(0xFF9C27B0), // Purple (refined)
    Color(0xFF7B1FA2), // Deep Purple (refined)
    Color(0xFFE91E63), // Pink (refined)
    Color(0xFFC2185B), // Deep Pink (refined)
    Color(0xFF00BCD4), // Cyan (refined)
    Color(0xFF0097A7), // Deep Cyan (refined)
  ];

  static String getColorName(Color color) {
    if (color == palette[0]) return 'Blue';
    if (color == palette[1]) return 'Deep Blue';
    if (color == palette[2]) return 'Green';
    if (color == palette[3]) return 'Deep Green';
    if (color == palette[4]) return 'Orange';
    if (color == palette[5]) return 'Deep Orange';
    if (color == palette[6]) return 'Purple';
    if (color == palette[7]) return 'Deep Purple';
    if (color == palette[8]) return 'Pink';
    if (color == palette[9]) return 'Deep Pink';
    if (color == palette[10]) return 'Cyan';
    if (color == palette[11]) return 'Deep Cyan';
    return 'Custom';
  }
}

/// Accent color state management
/// 
/// Manages accent color selection that SUBTLY influences the UI.
/// 
/// The accent color appears as:
/// - 5-8% opacity overlay on the app canvas
/// - Icon background tints
/// - Selection indicators
/// 
/// CRITICAL: The base canvas always remains neutral (off-white/charcoal).
/// The accent enhances, never dominates. This creates a calm, premium feel.
/// 
/// Uses ChangeNotifier for state management (no external dependencies).
class BackgroundController extends ChangeNotifier {
  BackgroundStyle _backgroundStyle = BackgroundStyle.solid;
  Color? _accentColor;

  /// Current background style
  BackgroundStyle get backgroundStyle => _backgroundStyle;

  /// Accent color (null = use theme default)
  /// Influences icon backgrounds and subtle overlays at low opacity
  Color? get accentColor => _accentColor;
  
  /// Legacy getter for backward compatibility
  @Deprecated('Use accentColor instead')
  Color? get customBackgroundColor => _accentColor;

  /// Set background style
  void setBackgroundStyle(BackgroundStyle style) {
    if (_backgroundStyle != style) {
      _backgroundStyle = style;
      notifyListeners();
    }
  }

  /// Set accent color
  void setAccentColor(Color? color) {
    if (_accentColor != color) {
      _accentColor = color;
      notifyListeners();
    }
  }
  
  /// Legacy method for backward compatibility
  @Deprecated('Use setAccentColor instead')
  void setCustomBackgroundColor(Color? color) => setAccentColor(color);

  /// Clear accent color (use theme default)
  void clearAccentColor() {
    if (_accentColor != null) {
      _accentColor = null;
      notifyListeners();
    }
  }
  
  /// Legacy method for backward compatibility
  @Deprecated('Use clearAccentColor instead')
  void clearCustomColor() => clearAccentColor();
}

