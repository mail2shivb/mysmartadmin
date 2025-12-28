import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for reminder operations
/// 
/// Thin layer above remindersDao - delegates to existing DAO methods
class RemindersRepository {
  final AppDatabase _database;

  RemindersRepository(this._database);

  /// Add a new reminder
  Future<int> addReminder({
    required String entityType,
    required int entityId,
    required String title,
    required DateTime reminderDate,
    required String reminderType,
    String? description,
    int? documentId,
    bool isRecurring = false,
    String? recurrencePattern,
  }) {
    return _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        title: title,
        reminderDate: reminderDate,
        reminderType: reminderType,
        description: Value(description),
        documentId: Value(documentId),
        isRecurring: Value(isRecurring),
        recurrencePattern: Value(recurrencePattern),
      ),
    );
  }

  /// Stream pending reminders
  Stream<List<ReminderEntity>> watchPendingReminders() {
    return _database.remindersDao.watchPendingReminders();
  }

  /// Mark reminder as completed
  Future<int> markReminderCompleted(int id) {
    return _database.remindersDao.completeReminder(id);
  }

  /// Snooze a reminder until specified time
  Future<int> snoozeReminder(int id, DateTime until) {
    return _database.remindersDao.snoozeReminder(id, until);
  }
}

