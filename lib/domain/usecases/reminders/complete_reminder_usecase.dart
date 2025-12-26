import '../../../data/local/app_database.dart';

/// Use case for completing a reminder
///
/// Marks reminder as completed with timestamp
class CompleteReminderUseCase {
  final AppDatabase _database;

  CompleteReminderUseCase(this._database);

  /// Mark a reminder as completed
  /// 
  /// Returns true if completion was successful
  Future<bool> call(int reminderId) async {
    if (reminderId <= 0) {
      throw ArgumentError('Invalid reminder ID');
    }

    // Verify reminder exists
    final reminder = await _database.remindersDao.getReminderById(reminderId);
    if (reminder == null) {
      throw StateError('Reminder with ID $reminderId not found');
    }

    // Validate status transition (cannot complete already completed reminder)
    if (reminder.status == 'completed') {
      throw StateError('Reminder is already completed');
    }

    // Complete the reminder
    final rowsAffected = await _database.remindersDao.completeReminder(reminderId);

    return rowsAffected > 0;
  }
}

