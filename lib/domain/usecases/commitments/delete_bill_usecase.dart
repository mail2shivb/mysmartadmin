import '../../../data/local/app_database.dart';

/// Use case for deleting a bill
///
/// Soft deletes the bill and cancels its auto-generated reminders
class DeleteBillUseCase {
  final AppDatabase _database;

  DeleteBillUseCase(this._database);

  /// Delete a bill and cancel its associated reminders
  Future<void> call(int billId) async {
    await _database.transaction(() async {
      await _database.billsDao.softDeleteBill(billId);
      await _database.remindersDao.cancelBillReminders(billId);
      await _database.remindersDao.cancelRemindersForEntity(
        entityType: 'bill',
        entityId: billId,
      );

    });
  }


}
