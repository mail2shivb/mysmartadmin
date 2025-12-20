import 'package:flutter/material.dart';

/// Centralized typography styles using Material 3 text theme
/// 
/// All text styles pull from the theme's text theme for consistency
/// and automatically adapt to light/dark mode.
class AppTypography {
  AppTypography._();

  /// Title large - for screen titles and major headings
  /// Default: 22px, medium weight
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }

  /// Title medium - for section headers and card titles
  /// Default: 16px, medium weight
  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  /// Title small - for small headers
  /// Default: 14px, medium weight
  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!;
  }

  /// Body large - for primary body text
  /// Default: 16px, regular weight
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!;
  }

  /// Body medium - for secondary body text
  /// Default: 14px, regular weight
  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  /// Body small - for captions and helper text
  /// Default: 12px, regular weight
  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!;
  }

  /// Label medium - for buttons and emphasized labels
  /// Default: 14px, medium weight
  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!;
  }

  /// Label small - for small labels and badges
  /// Default: 11px, medium weight
  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!;
  }

  /// Muted text - for de-emphasized content
  static TextStyle muted(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// Subtle text - for very de-emphasized content
  static TextStyle subtle(BuildContext context) {
    return bodySmall(context).copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

