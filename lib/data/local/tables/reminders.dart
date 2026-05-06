import 'package:drift/drift.dart';

/// Reminders — derived from documents or record instances.
///
/// Design rules (B6.2 / B6.4):
///   - Every reminder links to exactly one source entity via [sourceEntityKind] + [sourceEntityId].
///   - [triggerTypeId] is from the canonical vocabulary:
///       expiry_date | renewal_date | review_date | payment_due_date |
///       service_due_date | contract_end_date | trial_end_date | statement_available_date
///   - [leadInDaysSnapshot] is captured at creation so changing the global default
///     does not silently shift existing reminders.
///   - [firesAt] is precomputed (targetDate − leadInDays) for efficient indexed queries.
///   - Source deletion soft-cascades reminders to 'dismissed' at the app layer.
@DataClassName('ReminderEntity')
class Reminders extends Table {
  // ── Identity ──────────────────────────────────────────────────────────────

  IntColumn get id => integer().autoIncrement()();

  // ── Source linkage (polymorphic-lite) ─────────────────────────────────────

  /// Entity kind of the source record.
  /// 'document' | 'property' | 'vehicle' | 'account' | 'home_asset'
  TextColumn get sourceEntityKind => text()();

  /// Primary key of the source record within its table.
  IntColumn get sourceEntityId => integer()();

  // ── Trigger ───────────────────────────────────────────────────────────────

  /// Canonical trigger type from the taxonomy vocabulary.
  TextColumn get triggerTypeId => text()();

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// The actual date on the source record (e.g. expiry_date value).
  DateTimeColumn get targetDate => dateTime()();

  /// Lead-in days captured at creation time. Insulates existing reminders
  /// from future changes to the global lead-in configuration.
  IntColumn get leadInDaysSnapshot => integer().withDefault(const Constant(30))();

  /// Precomputed fire datetime = targetDate − leadInDaysSnapshot.
  /// Indexed for efficient "what fires today / this week" queries.
  DateTimeColumn get firesAt => dateTime()();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// 'pending' | 'due' | 'snoozed' | 'completed' | 'dismissed' | 'cancelled'
  TextColumn get state =>
      text().withDefault(const Constant('pending'))();

  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Optional user note attached to this reminder.
  TextColumn get userNote => text().nullable()();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  DateTimeColumn get deletedAt => dateTime().nullable()();

  // ── Audit ─────────────────────────────────────────────────────────────────

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
