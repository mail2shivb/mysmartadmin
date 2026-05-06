import 'package:flutter/widgets.dart';

/// Design tokens for spacing, sizing, and layout constants
/// 
/// Provides a consistent scale for spacing and sizing across the app.
/// All values follow an 8pt grid system for visual harmony.
class AppSpacing {
  AppSpacing._();

  /// Extra small spacing: 8dp
  static const double xs = 8.0;

  /// Small spacing: 12dp
  static const double sm = 12.0;

  /// Medium spacing: 16dp (base unit)
  static const double md = 16.0;

  /// Large spacing: 20dp
  static const double lg = 20.0;

  /// Extra large spacing: 24dp
  static const double xl = 24.0;

  /// Extra extra large spacing: 32dp
  static const double xxl = 32.0;

  /// Section gap spacing: 48dp (between major sections)
  static const double sectionGap = 48.0;
}

/// Design tokens for border radius
/// 
/// Provides consistent corner rounding across cards, buttons, and containers.
class AppRadius {
  AppRadius._();

  /// Small radius: 8dp
  static const double sm = 8.0;

  /// Medium radius: 12dp
  static const double md = 12.0;

  /// Large radius: 16dp
  static const double lg = 16.0;

  /// Circular radius
  static const double circular = 999.0;
}

/// Design tokens for sizes (tap targets, icons, etc.)
class AppSizes {
  AppSizes._();

  /// Minimum tap target size (accessibility): 48dp
  static const double minTapTarget = 48.0;

  /// Standard button height: 48dp
  static const double buttonHeight = 48.0;

  /// Small icon size: 20dp
  static const double iconSmall = 20.0;

  /// Medium icon size: 24dp
  static const double iconMedium = 24.0;

  /// Large icon size: 32dp
  static const double iconLarge = 32.0;

  /// Extra large icon size (empty states): 64dp
  static const double iconXLarge = 64.0;

  /// Avatar/badge small: 40dp
  static const double avatarSmall = 40.0;

  /// Avatar/badge medium: 48dp
  static const double avatarMedium = 48.0;

  /// Avatar/badge large: 56dp
  static const double avatarLarge = 56.0;
}

/// Design tokens for animation durations
class AppDurations {
  AppDurations._();

  /// Short animation: 150ms
  static const Duration short = Duration(milliseconds: 150);

  /// Medium animation: 250ms
  static const Duration medium = Duration(milliseconds: 250);

  /// Long animation: 400ms
  static const Duration long = Duration(milliseconds: 400);
}

/// Edge insets presets for common padding patterns
class AppPadding {
  AppPadding._();

  /// Standard screen padding: 16dp all sides
  static const EdgeInsets screen = EdgeInsets.all(AppSpacing.md);

  /// Screen padding with extra vertical: 24dp vertical, 16dp horizontal
  static const EdgeInsets screenVertical = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.xl,
  );

  /// Card padding: 16dp all sides
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.md);

  /// Section spacing: 16dp bottom
  static const EdgeInsets section = EdgeInsets.only(bottom: AppSpacing.md);

  /// Section spacing large: 24dp bottom
  static const EdgeInsets sectionLarge = EdgeInsets.only(bottom: AppSpacing.xl);
}

