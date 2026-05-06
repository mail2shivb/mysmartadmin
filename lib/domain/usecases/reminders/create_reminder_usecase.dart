import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';

/// Create a manual reminder for any source entity.
class CreateReminderUseCase {
  final AppDatabase _database;
  CreateReminderUseCase(this._database);

  Future<int> call({
    required String sourceEntityKind,
    required int sourceEntityId,
    required String triggerTypeId,
    required DateTime targetDate,
    int leadInDays = 30,
    String? userNote,
  }) async {
    if (sourceEntityKind.trim().isEmpty) {
      throw ArgumentError('Source entity kind cannot be empty');
    }
    if (triggerTypeId.trim().isEmpty) {
      throw ArgumentError('Trigger type cannot be empty');
    }

    DateRules.validateReasonableFutureDate(targetDate);

    final firesAt = targetDate.subtract(Duration(days: leadInDays));

    return _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        sourceEntityKind: sourceEntityKind,
        sourceEntityId: sourceEntityId,
        triggerTypeId: triggerTypeId,
        targetDate: targetDate,
        leadInDaysSnapshot: Value(leadInDays),
        firesAt: firesAt,
        userNote: Value(userNote),
      ),
    );
  }
}
