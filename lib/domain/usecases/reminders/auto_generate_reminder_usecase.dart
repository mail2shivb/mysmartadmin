import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/tables/reminders.dart';
import '../../validation/date_rules.dart';

/// Use case for auto-generating reminders for entities
///
/// Creates reminders linked to documents, preventing duplicates
class AutoGenerateReminderUseCase {
  final AppDatabase _database;

  AutoGenerateReminderUseCase(this._database);

  /// Auto-generate a reminder for a document
  /// 
  /// Only creates one auto reminder per document + reminder type combination.
  /// Skips if a matching reminder already exists.
  /// 
  /// Returns the reminder ID if created, or null if skipped (duplicate)
  Future<int?> call({
    required int documentId,
    required String reminderType,
    required DateTime reminderDate,
    required String title,
    String? description,
    int priority = 0,
  }) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    if (reminderType.trim().isEmpty) {
      throw ArgumentError('Reminder type cannot be empty');
    }

    if (title.trim().isEmpty) {
      throw ArgumentError('Reminder title cannot be empty');
    }

    // Validate reminder date using centralized validators
    DateRules.validateReasonableFutureDate(reminderDate);

    // Verify document exists
    final document = await _database.documentsDao.getDocumentById(documentId);
    if (document == null) {
      throw StateError('Document with ID $documentId not found');
    }

    // Check if auto reminder already exists for this document + type
    final existingReminders = await _database.remindersDao.getRemindersForDocument(documentId);
    
    final duplicateExists = existingReminders.any(
      (reminder) => reminder.reminderType == reminderType && reminder.status != 'completed',
    );

    // Skip if duplicate exists
    if (duplicateExists) {
      return null;
    }

    // Create the auto-generated reminder
    final reminderId = await _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        title: title,
        reminderDate: reminderDate,
        reminderType: reminderType,
        description: Value(description),
        documentId: Value(documentId),
        priority: Value(priority),
        status: const Value('pending'),
      ),
    );

    return reminderId;
  }
}

