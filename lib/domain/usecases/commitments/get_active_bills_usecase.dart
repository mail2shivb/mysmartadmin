import '../../../data/local/app_database.dart';

/// Use case for retrieving active bills
///
/// Fetches all active bills with optional filtering
class GetActiveBillsUseCase {
  final AppDatabase _database;

  GetActiveBillsUseCase(this._database);

  /// Get all active bills
  /// 
  /// Returns list of active bills sorted by next due date
  Future<List<BillEntity>> call({
    String? category,
    bool? isRecurring,
  }) async {
    // Get all active bills
    final activeBills = await _database.billsDao.getActiveBills();

    // Apply filters
    var filteredBills = activeBills;

    if (category != null && category.trim().isNotEmpty) {
      filteredBills = filteredBills.where((b) => b.category == category).toList();
    }

    if (isRecurring != null) {
      filteredBills = filteredBills.where((b) => b.isRecurring == isRecurring).toList();
    }

    // Sort by next due date (nulls last)
    filteredBills.sort((a, b) {
      if (a.nextDueDate == null && b.nextDueDate == null) return 0;
      if (a.nextDueDate == null) return 1;
      if (b.nextDueDate == null) return -1;
      return a.nextDueDate!.compareTo(b.nextDueDate!);
    });

    return filteredBills;
  }

  /// Get bills by category
  Future<List<BillEntity>> getByCategory(String category) async {
    if (category.trim().isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }

    return await _database.billsDao.getBillsByCategory(category);
  }

  /// Get recurring bills only
  Future<List<BillEntity>> getRecurring() async {
    return await _database.billsDao.getRecurringBills();
  }

  /// Get bills due within specified days
  Future<List<BillEntity>> getDueSoon(int days) async {
    if (days < 0) {
      throw ArgumentError('Days must be non-negative');
    }

    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return await _database.billsDao.getBillsDueBetween(now, endDate);
  }
}

