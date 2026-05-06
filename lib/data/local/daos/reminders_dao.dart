import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/reminders.dart';

part 'reminders_dao.g.dart';

/// DAO for [Reminders].
///
/// Key query pattern: use [firesAt] for "what fires today / this week" — it is
/// precomputed and indexed so the dashboard query is a single range scan.
/// [targetDate] holds the actual document date; use it for display only.
@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(AppDatabase db) : super(db);

  // ── CREATE ─────────────────────────────────────────────────────────────────

  Future<int> createReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<void> createReminders(List<RemindersCompanion> list) async {
    await batch((b) => b.insertAll(reminders, list));
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  Future<ReminderEntity?> getById(int id) =>
      (select(reminders)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.deletedAt.isNull()))
          .getSingleOrNull();

  Future<List<ReminderEntity>> getAll() =>
      (select(reminders)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .get();

  /// Reminders for a specific source entity.
  Future<List<ReminderEntity>> getForSource(
      String sourceEntityKind, int sourceEntityId) =>
      (select(reminders)
            ..where((t) =>
                t.sourceEntityKind.equals(sourceEntityKind) &
                t.sourceEntityId.equals(sourceEntityId))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .get();

  Future<List<ReminderEntity>> getByState(String state) =>
      (select(reminders)
            ..where((t) => t.state.equals(state))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .get();

  Future<List<ReminderEntity>> getPending() => getByState('pending');

  Future<List<ReminderEntity>> getOverdue() {
    final now = DateTime.now();
    return (select(reminders)
          ..where((t) => t.firesAt.isSmallerThanValue(now))
          // 'due' state is retired — only 'pending' is the active state.
          ..where((t) => t.state.equals('pending'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
        .get();
  }

  /// Returns actionable reminders that fire in [start, end].
  ///
  /// Snoozed reminders are intentionally excluded: their effective fire time
  /// has been deferred to [snoozedUntil] and they should not surface as
  /// active in this window until that date passes.
  Future<List<ReminderEntity>> getFiresBetween(
      DateTime start, DateTime end) =>
      (select(reminders)
            ..where((t) => t.firesAt.isBetweenValues(start, end))
            ..where((t) => t.deletedAt.isNull())
            // Exclude terminal/deferred states from upcoming-reminder views.
            ..where((t) => t.state.isNotIn(
                const ['snoozed', 'cancelled', 'dismissed', 'completed']))
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .get();

  Future<List<ReminderEntity>> getFiresOnDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getFiresBetween(start, end);
  }

  // ── Watch ─────────────────────────────────────────────────────────────────

  Stream<List<ReminderEntity>> watchAll() =>
      (select(reminders)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .watch();

  Stream<List<ReminderEntity>> watchPending() =>
      (select(reminders)
            ..where((t) => t.state.equals('pending'))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .watch();

  Stream<List<ReminderEntity>> watchForSource(
      String sourceEntityKind, int sourceEntityId) =>
      (select(reminders)
            ..where((t) =>
                t.sourceEntityKind.equals(sourceEntityKind) &
                t.sourceEntityId.equals(sourceEntityId))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.firesAt)]))
          .watch();

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  Future<bool> updateReminder(ReminderEntity reminder) =>
      update(reminders).replace(reminder);

  Future<int> complete(int id) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          state: const Value('completed'),
          completedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> snooze(int id, DateTime until) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          state: const Value('snoozed'),
          snoozedUntil: Value(until),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> dismiss(int id) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          state: const Value('dismissed'),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> updateTargetDate(int id, DateTime newDate,
      {required DateTime newFiresAt}) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          targetDate: Value(newDate),
          firesAt: Value(newFiresAt),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<int> softDelete(int id) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> hardDelete(int id) =>
      (delete(reminders)..where((t) => t.id.equals(id))).go();

  Future<int> restore(int id) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        const RemindersCompanion(deletedAt: Value(null)),
      );

  /// Soft-cascade: when a source record is deleted, dismiss its reminders.
  Future<void> dismissForSource(
      String sourceEntityKind, int sourceEntityId) async {
    final now = DateTime.now();
    await (update(reminders)
          ..where((t) =>
              t.sourceEntityKind.equals(sourceEntityKind) &
              t.sourceEntityId.equals(sourceEntityId))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.state.isNotIn(['completed', 'dismissed'])))
        .write(RemindersCompanion(
      state: const Value('dismissed'),
      updatedAt: Value(now),
    ));
  }

  /// Cancel all active reminders for a source (e.g. bill deleted).
  Future<void> cancelForSource(
      String sourceEntityKind, int sourceEntityId) async {
    final now = DateTime.now();
    await (update(reminders)
          ..where((t) =>
              t.sourceEntityKind.equals(sourceEntityKind) &
              t.sourceEntityId.equals(sourceEntityId))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.state.isNotIn(['completed', 'cancelled', 'dismissed'])))
        .write(RemindersCompanion(
      state: const Value('cancelled'),
      updatedAt: Value(now),
    ));
  }

  // ── STATISTICS ─────────────────────────────────────────────────────────────

  Future<int> countByState(String state) async {
    final q = selectOnly(reminders)
      ..addColumns([reminders.id.count()])
      ..where(reminders.state.equals(state))
      ..where(reminders.deletedAt.isNull());
    final r = await q.getSingle();
    return r.read(reminders.id.count()) ?? 0;
  }

  Future<int> countPending() => countByState('pending');

  Future<int> countOverdue() async {
    final now = DateTime.now();
    final q = selectOnly(reminders)
      ..addColumns([reminders.id.count()])
      ..where(reminders.firesAt.isSmallerThanValue(now))
      // 'due' state is retired; 'pending' is the only active state.
      ..where(reminders.state.equals('pending'))
      ..where(reminders.deletedAt.isNull());
    final r = await q.getSingle();
    return r.read(reminders.id.count()) ?? 0;
  }

  /// Count of reminders that need user attention: pending and not soft-deleted.
  ///
  /// "Actionable" means the reminder is in the only active state ('pending'),
  /// is not soft-deleted, and is not snoozed. This is the number surfaced on
  /// dashboard badges and notification counts.
  Future<int> countActionable() async {
    final q = selectOnly(reminders)
      ..addColumns([reminders.id.count()])
      ..where(reminders.state.equals('pending'))
      ..where(reminders.snoozedUntil.isNull() |
          reminders.snoozedUntil.isSmallerThanValue(DateTime.now()))
      ..where(reminders.deletedAt.isNull());
    final r = await q.getSingle();
    return r.read(reminders.id.count()) ?? 0;
  }
}
