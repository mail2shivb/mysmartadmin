import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/reminders.dart';

part 'reminders_dao.g.dart';

/// Data Access Object for Reminders
/// 
/// Manages reminders for documents and custom alerts
@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase> with _$RemindersDaoMixin {
  RemindersDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new reminder
  Future<int> createReminder(RemindersCompanion reminder) {
    return into(reminders).insert(reminder);
  }

  /// Create multiple reminders
  Future<void> createReminders(List<RemindersCompanion> reminderList) async {
    await batch((batch) {
      batch.insertAll(reminders, reminderList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a reminder by ID
  Future<ReminderEntity?> getReminderById(int id) {
    return (select(reminders)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all reminders
  Future<List<ReminderEntity>> getAllReminders() {
    return (select(reminders)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Get reminders for a specific document
  Future<List<ReminderEntity>> getRemindersForDocument(int documentId) {
    return (select(reminders)
          ..where((t) => t.documentId.equals(documentId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Get reminders by status
  Future<List<ReminderEntity>> getRemindersByStatus(String status) {
    return (select(reminders)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Get pending reminders
  Future<List<ReminderEntity>> getPendingReminders() {
    return (select(reminders)
          ..where((t) => t.status.equals('pending'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Get overdue reminders
  Future<List<ReminderEntity>> getOverdueReminders() {
    final now = DateTime.now();
    return (select(reminders)
          ..where((t) => t.reminderDate.isSmallerThanValue(now))
          ..where((t) => t.status.equals('pending') | t.status.equals('overdue'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Get reminders due within a date range
  Future<List<ReminderEntity>> getRemindersDueBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(reminders)
          ..where((t) => t.reminderDate.isBetweenValues(start, end))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Get reminders due today
  Future<List<ReminderEntity>> getRemindersForToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getRemindersDueBetween(startOfDay, endOfDay);
  }

  /// Get recurring reminders
  Future<List<ReminderEntity>> getRecurringReminders() {
    return (select(reminders)
          ..where((t) => t.isRecurring.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .get();
  }

  /// Stream all reminders
  Stream<List<ReminderEntity>> watchAllReminders() {
    return (select(reminders)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .watch();
  }

  /// Stream pending reminders
  Stream<List<ReminderEntity>> watchPendingReminders() {
    return (select(reminders)
          ..where((t) => t.status.equals('pending'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a reminder
  Future<bool> updateReminder(ReminderEntity reminder) {
    return update(reminders).replace(reminder);
  }

  /// Mark reminder as completed
  Future<int> completeReminder(int id) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        status: const Value('completed'),
        completedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Snooze a reminder
  Future<int> snoozeReminder(int id, DateTime snoozeUntil) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        status: const Value('snoozed'),
        snoozeUntil: Value(snoozeUntil),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark reminder as overdue
  Future<int> markAsOverdue(int id) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        status: const Value('overdue'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update reminder date
  Future<int> updateReminderDate(int id, DateTime newDate) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        reminderDate: Value(newDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a reminder
  Future<int> softDeleteReminder(int id) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a reminder
  Future<int> hardDeleteReminder(int id) {
    return (delete(reminders)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted reminder
  Future<int> restoreReminder(int id) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      const RemindersCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count reminders by status
  Future<int> countRemindersByStatus(String status) async {
    final query = selectOnly(reminders)
      ..addColumns([reminders.id.count()])
      ..where(reminders.status.equals(status))
      ..where(reminders.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(reminders.id.count()) ?? 0;
  }

  /// Count pending reminders
  Future<int> countPendingReminders() async {
    return countRemindersByStatus('pending');
  }

  /// Count overdue reminders
  Future<int> countOverdueReminders() async {
    final now = DateTime.now();
    final query = selectOnly(reminders)
      ..addColumns([reminders.id.count()])
      ..where(reminders.reminderDate.isSmallerThanValue(now))
      ..where(reminders.status.equals('pending') | reminders.status.equals('overdue'))
      ..where(reminders.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(reminders.id.count()) ?? 0;
  }
}

