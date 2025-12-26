import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/tables/reminders.dart';
import '../../validation/entity_validators.dart';

/// Use case for creating a manual reminder
///
/// Creates a new reminder with validation and returns the reminder ID
class CreateReminderUseCase {
  final AppDatabase _database;

  CreateReminderUseCase(this._database);

  /// Create a new reminder
  /// 
  /// Returns the ID of the newly created reminder
  Future<int> call({
    required String title,
    required DateTime reminderDate,
    required String reminderType,
    String? description,
    int? documentId,
    bool isRecurring = false,
    String? recurrencePattern,
    int priority = 0,
  }) async {
    // Use centralized entity validator
    EntityValidators.validateReminder(
      title: title,
      reminderDate: reminderDate,
      reminderType: reminderType,
    );

    // Validate documentId if provided
    if (documentId != null && documentId > 0) {
      final document = await _database.documentsDao.getDocumentById(documentId);
      if (document == null) {
        throw StateError('Document with ID $documentId not found');
      }
    }

    // Create the reminder with status = pending
    final reminderId = await _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        title: title,
        reminderDate: reminderDate,
        reminderType: reminderType,
        description: Value(description),
        documentId: Value(documentId),
        isRecurring: Value(isRecurring),
        recurrencePattern: Value(recurrencePattern),
        priority: Value(priority),
        status: const Value('pending'),
      ),
    );

    return reminderId;
  }
}

