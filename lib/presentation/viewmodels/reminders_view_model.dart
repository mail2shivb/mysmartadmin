// B12 STATUS: IMPLEMENTED

import '../../domain/reports/reports_repository.dart';
import '../../domain/reports/dto/upcoming_reminder_view.dart';
import '../../data/local/app_database.dart';

/// Reminders ViewModel
///
/// Thin adapter for reminders UI to fetch reminder data.
/// Calls ReportsRepository and returns DTOs directly.
/// Contains NO business logic, NO caching, NO mutation.
class RemindersViewModel {
  final ReportsRepository _repository;

  RemindersViewModel(this._repository);

  /// Load reminders due between specific dates
  ///
  /// Returns list of reminders with days until due calculated.
  /// [from] Start date of range
  /// [to] End date of range
  Future<List<UpcomingReminderView>> loadUpcomingReminders({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _repository.getUpcomingReminders(from: from, to: to);
  }

  /// Load reminders due within next N days
  ///
  /// Convenience method for common "upcoming" use case.
  /// [daysAhead] defaults to 7 days.
  Future<List<UpcomingReminderView>> loadRemindersDueSoon({
    int daysAhead = 7,
  }) async {
    return await _repository.getRemindersDueSoon(daysAhead: daysAhead);
  }

  /// Load overdue reminders
  ///
  /// Returns reminders with due date in the past.
  Future<List<ReminderEntity>> loadOverdueReminders() async {
    return await _repository.getOverdueReminders();
  }

  /// Load reminders grouped by entity type
  ///
  /// Returns map: entityType → list of reminders
  Future<Map<String, List<ReminderEntity>>> loadRemindersByEntityType() async {
    return await _repository.getRemindersByEntityType();
  }

  /// Count pending reminders
  ///
  /// Returns total count of reminders with 'pending' status.
  Future<int> countPendingReminders() async {
    return await _repository.countPendingReminders();
  }

  /// Count overdue reminders
  ///
  /// Returns total count of reminders past their due date.
  Future<int> countOverdueReminders() async {
    return await _repository.countOverdueReminders();
  }

  /// Load reminder counts grouped by status
  ///
  /// Returns map: status → count
  Future<Map<String, int>> loadReminderCountsByStatus() async {
    return await _repository.getReminderCountsByStatus();
  }

  /// Load reminders for a specific entity
  ///
  /// Returns all reminders linked to the given entity.
  /// [entityType] Type of entity (e.g., 'bill', 'policy')
  /// [entityId] ID of the entity
  Future<List<ReminderEntity>> loadRemindersForEntity({
    required String entityType,
    required int entityId,
  }) async {
    return await _repository.getRemindersForEntity(
      entityType: entityType,
      entityId: entityId,
    );
  }
}

