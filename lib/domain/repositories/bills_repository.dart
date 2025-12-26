import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for bill operations
/// 
/// Thin layer above billsDao - delegates to existing DAO methods
class BillsRepository {
  final AppDatabase _database;

  BillsRepository(this._database);

  /// Add a new bill
  Future<int> addBill({
    required String billName,
    required String category,
    required String provider,
    required int amountCents,
    required DateTime nextDueDate,
    bool isRecurring = false,
    String? frequency,
    bool isAutoPay = false,
  }) {
    return _database.billsDao.createBill(
      BillsCompanion.insert(
        name: billName,
        category: category,
        provider: Value(provider),
        amountCents: amountCents,
        nextDueDate: Value(nextDueDate),
        isRecurring: Value(isRecurring),
        frequency: Value(frequency),
        isAutoPay: Value(isAutoPay),
      ),
    );
  }

  /// Stream active bills
  Stream<List<BillEntity>> watchActiveBills() {
    return _database.billsDao.watchAllBills();
  }

  /// Get a single bill by ID
  Future<BillEntity?> getBillById(int id) {
    return _database.billsDao.getBillById(id);
  }

  /// Calculate total monthly bills amount (in cents)
  Future<int> calculateMonthlyTotal() {
    return _database.billsDao.calculateMonthlyTotal();
  }

  /// Soft delete a bill (can be restored later)
  Future<int> softDeleteBill(int id) {
    return _database.billsDao.softDeleteBill(id);
  }
}

