import '../../../data/local/app_database.dart';

class DeleteBillUseCase {
  final AppDatabase _database;
  DeleteBillUseCase(this._database);

  Future<void> call(int billId) async {
    await _database.transaction(() async {
      await _database.billsDao.softDeleteBill(billId);
      await _database.remindersDao.cancelForSource('bill', billId);
    });
  }
}
