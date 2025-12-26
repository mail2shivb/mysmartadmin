import 'package:drift/drift.dart';
import 'documents.dart';

/// Reminders table - for expiry, renewal, and custom reminders
@DataClassName('ReminderEntity')
class Reminders extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - optional link to document
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.cascade)();

  // Reminder details
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get reminderType => text()(); // 'expiry', 'renewal', 'review', 'custom'

  // Scheduling
  DateTimeColumn get reminderDate => dateTime()();
  DateTimeColumn get snoozeUntil => dateTime().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrencePattern => text().nullable()(); // JSON: {interval: 'monthly', count: 12}

  // Status
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'snoozed', 'completed', 'overdue'
  DateTimeColumn get completedAt => dateTime().nullable()();

  // Priority
  IntColumn get priority => integer().withDefault(const Constant(0))(); // 0=normal, 1=high, -1=low

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

