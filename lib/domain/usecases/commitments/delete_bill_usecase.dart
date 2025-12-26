import '../../../data/local/app_database.dart';

/// Use case for deleting a bill
///
/// Soft deletes the bill and cancels associated reminders
class DeleteBillUseCase {
  final AppDatabase _database;

  DeleteBillUseCase(this._database);

  /// Delete a bill and its associated reminders
  /// 
  /// Returns true if successful
  Future<bool> call(int billId) async {
    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // 1. Soft delete the bill
      final billRowsAffected = await _database.billsDao.softDeleteBill(billId);

      // 2. Find and cancel all reminders linked to this bill
      final allReminders = await _database.remindersDao.getAllReminders();
      final billReminders = allReminders.where(
        (r) => r.description != null && 
               r.description!.contains('[ENTITY:bill:$billId]'),
      );

      // 3. Soft delete each reminder
      for (final reminder in billReminders) {
        await _database.remindersDao.softDeleteReminder(reminder.id);
      }

      return billRowsAffected > 0;
    });
  }
}

