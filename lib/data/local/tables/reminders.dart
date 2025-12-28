import 'package:drift/drift.dart';
import 'documents.dart';

@DataClassName('ReminderEntity')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Optional document link
  IntColumn get documentId =>
      integer().nullable().references(Documents, #id, onDelete: KeyAction.cascade)();

  // 🔐 ENTITY IDENTITY (REQUIRED for isolation)
  TextColumn get entityType => text()();        // 'bill', 'subscription', 'policy', 'document'
  IntColumn get entityId => integer()();

  // Reminder details
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get reminderType => text()();

  // Scheduling
  DateTimeColumn get reminderDate => dateTime()();
  DateTimeColumn get snoozeUntil => dateTime().nullable()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurrencePattern => text().nullable()();

  // Status
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // Soft delete
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
