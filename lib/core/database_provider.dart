import '../data/local/app_database.dart';

/// Simple database singleton for UI access
class DatabaseProvider {
  static AppDatabase? _instance;
  
  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
}

