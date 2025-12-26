import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';
import '../../validation/domain_exceptions.dart';

/// Use case for snoozing a reminder
///
/// Updates reminder status to snoozed and sets snooze_until date
class SnoozeReminderUseCase {
  final AppDatabase _database;

  SnoozeReminderUseCase(this._database);

  /// Snooze a reminder until specified date
  /// 
  /// Returns true if snooze was successful
  Future<bool> call({
    required int reminderId,
    required DateTime snoozeUntil,
  }) async {
    if (reminderId <= 0) {
      throw ArgumentError('Invalid reminder ID');
    }

    // Validate snooze date using centralized validators
    DateRules.validateFutureDate(snoozeUntil);
    DateRules.validateReasonableFutureDate(snoozeUntil);

    // Verify reminder exists
    final reminder = await _database.remindersDao.getReminderById(reminderId);
    if (reminder == null) {
      throw StateError('Reminder with ID $reminderId not found');
    }

    // Validate snooze date is after original reminder date
    if (snoozeUntil.isBefore(reminder.reminderDate)) {
      throw const InvalidDateException('Snooze date must be after original reminder date');
    }

    // Validate status transition (can only snooze pending or overdue reminders)
    if (reminder.status != 'pending' && reminder.status != 'overdue') {
      throw StateError('Can only snooze pending or overdue reminders');
    }

    // Snooze the reminder
    final rowsAffected = await _database.remindersDao.snoozeReminder(
      reminderId,
      snoozeUntil,
    );

    return rowsAffected > 0;
  }
}

