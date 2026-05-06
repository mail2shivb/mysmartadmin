import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for reminder operations.
///
/// Thin layer above [RemindersDao] — translates domain parameters to the
/// B8 reminder model (sourceEntityKind/Id, triggerTypeId, firesAt).
class RemindersRepository {
  final AppDatabase _database;

  RemindersRepository(this._database);

  /// Create a new reminder derived from a source record.
  ///
  /// [leadInDays] controls how far before [targetDate] the reminder fires.
  /// The snapshot is stored independently so global config changes don't
  /// retro-shift existing reminders.
  Future<int> addReminder({
    required String sourceEntityKind,
    required int sourceEntityId,
    required String triggerTypeId,
    required DateTime targetDate,
    int leadInDays = 30,
    String? userNote,
  }) {
    final firesAt = targetDate.subtract(Duration(days: leadInDays));
    return _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        sourceEntityKind: sourceEntityKind,
        sourceEntityId: sourceEntityId,
        triggerTypeId: triggerTypeId,
        targetDate: targetDate,
        leadInDaysSnapshot: Value(leadInDays),
        firesAt: firesAt,
        userNote: Value(userNote),
      ),
    );
  }

  /// Stream reminders currently in the pending state.
  Stream<List<ReminderEntity>> watchPendingReminders() =>
      _database.remindersDao.watchPending();

  /// Mark a reminder as completed.
  Future<int> markReminderCompleted(int id) =>
      _database.remindersDao.complete(id);

  /// Snooze a reminder until [until].
  Future<int> snoozeReminder(int id, DateTime until) =>
      _database.remindersDao.snooze(id, until);

  /// Dismiss a reminder (user-acknowledged, not completed).
  Future<int> dismissReminder(int id) =>
      _database.remindersDao.dismiss(id);

  /// Cancel all active reminders for a source entity when that entity is deleted.
  Future<void> cancelForSource(String kind, int entityId) =>
      _database.remindersDao.cancelForSource(kind, entityId);
}
