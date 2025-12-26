import 'package:drift/drift.dart';
import 'documents.dart';
import 'properties.dart';
import 'vehicles.dart';
import 'home_assets.dart';

/// Tasks table - user and system-generated tasks
@DataClassName('TaskEntity')
class Tasks extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign keys - link to related entities
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();
  IntColumn get propertyId => integer().nullable().references(Properties, #id, onDelete: KeyAction.setNull)();
  IntColumn get vehicleId => integer().nullable().references(Vehicles, #id, onDelete: KeyAction.setNull)();
  IntColumn get homeAssetId => integer().nullable().references(HomeAssets, #id, onDelete: KeyAction.setNull)();

  // Task details
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get taskType => text()(); // 'system_generated', 'user_created', 'recurring'
  TextColumn get category => text().nullable()(); // 'maintenance', 'renewal', 'review', 'compliance', 'financial', etc.

  // Status
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'in_progress', 'completed', 'cancelled', 'overdue'
  IntColumn get priority => integer().withDefault(const Constant(0))(); // -1: low, 0: normal, 1: high, 2: urgent

  // Dates
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();

  // Recurring task support
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrencePattern => text().nullable()(); // JSON: {interval: 'monthly', count: 12}
  DateTimeColumn get nextOccurrence => dateTime().nullable()();

  // Assignment
  TextColumn get assignedTo => text().nullable()(); // For future multi-user support
  TextColumn get source => text().withDefault(const Constant('user'))(); // 'user', 'system', 'reminder'

  // Additional details (JSON)
  TextColumn get checklist => text().nullable()(); // JSON array of subtasks/checklist items
  TextColumn get metadata => text().nullable()(); // Additional task-specific data

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

