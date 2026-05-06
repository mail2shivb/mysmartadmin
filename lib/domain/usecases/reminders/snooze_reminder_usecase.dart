import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';
import '../../validation/domain_exceptions.dart';

class SnoozeReminderUseCase {
  final AppDatabase _database;
  SnoozeReminderUseCase(this._database);

  Future<bool> call({
    required int reminderId,
    required DateTime snoozeUntil,
  }) async {
    if (reminderId <= 0) throw ArgumentError('Invalid reminder ID');

    DateRules.validateFutureDate(snoozeUntil);
    DateRules.validateReasonableFutureDate(snoozeUntil);

    final reminder = await _database.remindersDao.getById(reminderId);
    if (reminder == null) throw StateError('Reminder $reminderId not found');

    if (snoozeUntil.isBefore(reminder.firesAt)) {
      throw const InvalidDateException(
          'Snooze date must be after current fires-at date');
    }
    if (reminder.state != 'pending' && reminder.state != 'due') {
      throw StateError('Can only snooze pending or due reminders');
    }

    final rows = await _database.remindersDao.snooze(reminderId, snoozeUntil);
    return rows > 0;
  }
}
