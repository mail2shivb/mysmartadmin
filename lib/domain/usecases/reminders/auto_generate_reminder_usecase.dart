import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';

/// Auto-generate a reminder for a document, preventing duplicates per trigger type.
class AutoGenerateReminderUseCase {
  final AppDatabase _database;
  AutoGenerateReminderUseCase(this._database);

  /// Returns the reminder ID if created, or null if skipped (duplicate exists).
  Future<int?> call({
    required int documentId,
    required String triggerTypeId,
    required DateTime targetDate,
    int leadInDays = 30,
    String? userNote,
  }) async {
    if (documentId <= 0) throw ArgumentError('Invalid document ID');
    if (triggerTypeId.trim().isEmpty) throw ArgumentError('Trigger type cannot be empty');

    DateRules.validateReasonableFutureDate(targetDate);

    final document = await _database.documentsDao.getDocumentById(documentId);
    if (document == null) throw StateError('Document $documentId not found');

    final firesAt = targetDate.subtract(Duration(days: leadInDays));

    // A reminder that would fire in the past is silently skipped: the user
    // missed the lead-in window and the target date is imminent / already past.
    if (firesAt.isBefore(DateTime.now())) return null;

    // Wrap the duplicate-check and insert in a single transaction to eliminate
    // the TOCTOU gap where two concurrent calls could both pass the dup-check
    // and both insert, creating a duplicate reminder.
    return _database.transaction(() async {
      final existing =
          await _database.remindersDao.getForSource('document', documentId);
      final dup = existing.any((r) =>
          r.triggerTypeId == triggerTypeId && r.state != 'completed');
      if (dup) return null;

      return _database.remindersDao.createReminder(
        RemindersCompanion.insert(
          sourceEntityKind: 'document',
          sourceEntityId: documentId,
          triggerTypeId: triggerTypeId,
          targetDate: targetDate,
          leadInDaysSnapshot: Value(leadInDays),
          firesAt: firesAt,
          userNote: Value(userNote),
        ),
      );
    });
  }
}
