// F1.6 STATUS: IMPLEMENTED

/// Spacing system for consistent layout
/// 
/// Uses 8pt grid system following Material Design guidelines
/// Optimized for hierarchy and breathing space in canvas + sheet model
class Spacing {
  Spacing._();

  /// Extra small spacing (8dp)
  static const double xs = 8.0;

  /// Small spacing (12dp)
  static const double sm = 12.0;

  /// Medium spacing (16dp) - default for most cases
  static const double md = 16.0;

  /// Large spacing (20dp)
  static const double lg = 20.0;

  /// Extra large spacing (24dp)
  static const double xl = 24.0;

  /// Extra extra large spacing (32dp)
  static const double xxl = 32.0;

  /// Section header top margin (40dp) - strong visual separation
  static const double sectionHeaderTop = 40.0;

  /// Section header to content gap (12dp) - close to their cards
  static const double sectionHeaderBottom = 12.0;
}


