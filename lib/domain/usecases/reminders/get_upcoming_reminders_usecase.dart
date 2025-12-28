import '../../../data/local/app_database.dart';

/// Use case for retrieving upcoming reminders
///
/// Fetches pending reminders within a lookahead period
class GetUpcomingRemindersUseCase {
  final AppDatabase _database;

  GetUpcomingRemindersUseCase(this._database);

  /// Get upcoming reminders
  /// 
  /// Fetches reminders with:
  /// - status = pending
  /// - reminderDate <= now + lookaheadDays
  /// 
  /// Results are sorted ascending by reminderDate
  Future<List<ReminderEntity>> call({
    int lookaheadDays = 7,
  }) async {
    if (lookaheadDays < 0) {
      throw ArgumentError('Lookahead days must be non-negative');
    }

    final now = DateTime.now();
    final endDate = now.add(Duration(days: lookaheadDays));

    // Get pending reminders within the date range
    final allReminders = await _database.remindersDao.getRemindersDueBetween(
      now,
      endDate,
    );

    // Filter to only pending status and sort by reminderDate ascending
    final upcomingReminders = allReminders
        .where((reminder) => reminder.status == 'pending')
        .toList()
      ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

    return upcomingReminders;
  }

  /// Get all pending reminders (no date filter)
  Future<List<ReminderEntity>> getAllPending() async {
    return await _database.remindersDao.getPendingReminders();
  }

  /// Get overdue reminders (reminderDate < now and status = pending/overdue)
  Future<List<ReminderEntity>> getOverdue() async {
    return await _database.remindersDao.getOverdueReminders();
  }

  /// Get reminders for a specific document
  Future<List<ReminderEntity>> getForDocument(int documentId) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    return await _database.remindersDao.getRemindersForDocument(documentId);
  }
}

