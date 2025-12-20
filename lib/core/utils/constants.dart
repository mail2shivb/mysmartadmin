/// Application-wide constants
/// 
/// Principles:
/// - Offline-first
/// - Privacy-first
/// - No cloud endpoints
class AppConstants {
  AppConstants._();

  /// Application metadata
  static const String appName = 'LedgerAI';
  static const String appVersion = '0.1.0';

  /// Privacy statement
  static const String privacyStatement =
      'All data stored locally on device. No cloud sync. No analytics.';

  /// UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;

  /// Navigation labels (for bottom nav)
  static const String navHome = 'Home';
  static const String navDocuments = 'Documents';
  static const String navCategories = 'Categories';
  static const String navQuery = 'Search';
  static const String navTasks = 'Tasks';
}

