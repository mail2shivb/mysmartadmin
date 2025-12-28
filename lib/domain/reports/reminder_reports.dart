// B11.1 STATUS: IMPLEMENTED

import '../../data/local/app_database.dart';
import 'dto/upcoming_reminder_view.dart';

/// Reminder-specific reports service
/// 
/// Read-only queries for reminder analytics and insights
class ReminderReports {
  final AppDatabase _database;

  ReminderReports(this._database);

  /// Get reminders due between from and to dates
  /// 
  /// Excludes cancelled and deleted reminders
  /// Orders by due date ascending
  Future<List<UpcomingReminderView>> upcoming({
    required DateTime from,
    required DateTime to,
  }) async {
    // Query reminders in date range, excluding cancelled and deleted
    final reminders = await _database.remindersDao.getRemindersDueBetween(
      from,
      to,
    );

    // Filter out cancelled reminders
    final activeReminders = reminders.where(
      (r) => r.status != 'cancelled',
    ).toList();

    // Map to UpcomingReminderView and calculate daysUntilDue
    final now = DateTime.now();
    return activeReminders.map((r) {
      final daysUntilDue = r.reminderDate.difference(now).inDays;
      
      return UpcomingReminderView(
        reminderId: r.id,
        entityType: r.entityType,
        entityId: r.entityId,
        title: r.title,
        reminderDate: r.reminderDate,
        reminderType: r.reminderType,
        status: r.status,
        daysUntilDue: daysUntilDue,
      );
    }).toList();
  }

  /// Get reminders due within next N days
  Future<List<UpcomingReminderView>> getRemindersDueSoon({
    int daysAhead = 7,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));
    
    return await upcoming(from: now, to: endDate);
  }

  /// Get overdue reminders
  Future<List<ReminderEntity>> getOverdueReminders() async {
    return await _database.remindersDao.getOverdueReminders();
  }

  /// Get reminders by entity type
  Future<Map<String, List<ReminderEntity>>> getRemindersByEntityType() async {
    final allReminders = await _database.remindersDao.getAllReminders();
    
    final Map<String, List<ReminderEntity>> grouped = {};
    for (final reminder in allReminders) {
      grouped.putIfAbsent(reminder.entityType, () => []).add(reminder);
    }
    
    return grouped;
  }

  /// Count pending reminders
  Future<int> countPendingReminders() async {
    return await _database.remindersDao.countPendingReminders();
  }

  /// Count overdue reminders
  Future<int> countOverdueReminders() async {
    return await _database.remindersDao.countOverdueReminders();
  }

  /// Get reminders by status
  Future<Map<String, int>> getReminderCountsByStatus() async {
    final allReminders = await _database.remindersDao.getAllReminders();
    
    final Map<String, int> counts = {};
    for (final reminder in allReminders) {
      counts[reminder.status] = (counts[reminder.status] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Get reminders for specific entity
  Future<List<ReminderEntity>> getRemindersForEntity({
    required String entityType,
    required int entityId,
  }) async {
    final allReminders = await _database.remindersDao.getAllReminders();
    
    return allReminders.where(
      (r) => r.entityType == entityType && r.entityId == entityId,
    ).toList();
  }
}

