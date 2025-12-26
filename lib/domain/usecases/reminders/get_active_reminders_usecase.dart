import '../../../data/local/app_database.dart';

/// Use case for retrieving active (pending) reminders
///
/// Returns all non-deleted reminders with pending status
class GetActiveRemindersUseCase {
  final AppDatabase _database;

  GetActiveRemindersUseCase(this._database);

  /// Get all active (pending) reminders
  /// 
  /// Returns reminders that are:
  /// - Not soft-deleted
  /// - Status = 'pending'
  Future<List<ReminderEntity>> call() async {
    return await _database.remindersDao.getPendingReminders();
  }
}

