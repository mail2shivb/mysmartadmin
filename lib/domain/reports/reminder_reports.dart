// B11.1 STATUS: IMPLEMENTED

import '../../data/local/app_database.dart';
import 'dto/upcoming_reminder_view.dart';

/// Reminder-specific reports service.
///
/// Read-only queries for reminder analytics and upcoming views.
class ReminderReports {
  final AppDatabase _database;

  ReminderReports(this._database);

  /// Reminders that fire between [from] and [to], excluding cancelled/dismissed.
  Future<List<UpcomingReminderView>> upcoming({
    required DateTime from,
    required DateTime to,
  }) async {
    // getFiresBetween already excludes snoozed/cancelled/dismissed/completed.
    final reminders = await _database.remindersDao.getFiresBetween(from, to);
    final active = reminders.toList();

    final now = DateTime.now();
    return active.map((r) {
      return UpcomingReminderView(
        reminderId: r.id,
        sourceEntityKind: r.sourceEntityKind,
        sourceEntityId: r.sourceEntityId,
        triggerTypeId: r.triggerTypeId,
        firesAt: r.firesAt,
        targetDate: r.targetDate,
        state: r.state,
        daysUntilDue: r.firesAt.difference(now).inDays,
        userNote: r.userNote,
      );
    }).toList();
  }

  /// Reminders firing within the next [daysAhead] days.
  Future<List<UpcomingReminderView>> getRemindersDueSoon({
    int daysAhead = 7,
  }) {
    final now = DateTime.now();
    return upcoming(from: now, to: now.add(Duration(days: daysAhead)));
  }

  /// Reminders that are overdue (firesAt in the past, state pending/due).
  Future<List<ReminderEntity>> getOverdueReminders() =>
      _database.remindersDao.getOverdue();

  /// Reminders grouped by their source entity kind.
  Future<Map<String, List<ReminderEntity>>> getRemindersByEntityKind() async {
    final all = await _database.remindersDao.getAll();
    final Map<String, List<ReminderEntity>> grouped = {};
    for (final r in all) {
      grouped.putIfAbsent(r.sourceEntityKind, () => []).add(r);
    }
    return grouped;
  }

  /// Count of pending reminders.
  Future<int> countPendingReminders() =>
      _database.remindersDao.countPending();

  /// Count of overdue reminders.
  Future<int> countOverdueReminders() =>
      _database.remindersDao.countOverdue();

  /// Reminder counts keyed by state.
  Future<Map<String, int>> getReminderCountsByState() async {
    final all = await _database.remindersDao.getAll();
    final Map<String, int> counts = {};
    for (final r in all) {
      counts[r.state] = (counts[r.state] ?? 0) + 1;
    }
    return counts;
  }

  /// All reminders for a specific source entity.
  Future<List<ReminderEntity>> getRemindersForEntity({
    required String sourceEntityKind,
    required int sourceEntityId,
  }) =>
      _database.remindersDao.getForSource(sourceEntityKind, sourceEntityId);
}
