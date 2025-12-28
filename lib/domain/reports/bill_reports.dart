// B11.2 STATUS: IMPLEMENTED

import '../../data/local/app_database.dart';

/// Bill-specific reports service
/// 
/// Read-only queries for bill analytics and insights
class BillReports {
  final AppDatabase _database;

  BillReports(this._database);

  /// Get total monthly bill costs
  /// 
  /// Uses version-aware filtering (latest versions only)
  Future<int> getMonthlyTotal() async {
    return await _database.billsDao.calculateMonthlyTotal();
  }

  /// Get bills by category with totals
  /// 
  /// Returns monthly costs grouped by category
  Future<Map<String, int>> getMonthlyCostsByCategory() async {
    final activeBills = await _database.billsDao.getActiveBills();
    
    final Map<String, int> categoryTotals = {};
    
    for (final bill in activeBills) {
      if (bill.isRecurring) {
        int monthlyAmount = _convertToMonthly(
          bill.amountCents,
          bill.frequency ?? 'monthly',
        );
        
        categoryTotals[bill.category] = 
            (categoryTotals[bill.category] ?? 0) + monthlyAmount;
      }
    }
    
    return categoryTotals;
  }

  /// Get bills due within next N days
  Future<List<BillEntity>> getBillsDueSoon({int daysAhead = 7}) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));
    
    return await _database.billsDao.getBillsDueBetween(now, endDate);
  }

  /// Get overdue bills
  /// 
  /// Returns bills with nextDueDate in the past
  Future<List<BillEntity>> getOverdueBills() async {
    final allBills = await _database.billsDao.getActiveBills();
    final now = DateTime.now();
    
    return allBills.where((bill) {
      return bill.nextDueDate != null && 
             bill.nextDueDate!.isBefore(now);
    }).toList();
  }

  /// Count active bills
  Future<int> countActiveBills() async {
    return await _database.billsDao.countActiveBills();
  }

  /// Get highest cost bills (top N)
  /// 
  /// Returns bills sorted by monthly cost descending
  Future<List<BillEntity>> getHighestCostBills({int limit = 5}) async {
    final activeBills = await _database.billsDao.getActiveBills();
    
    // Calculate monthly equivalent for each bill
    final billsWithMonthlyCost = activeBills.map((bill) {
      final monthlyCost = _convertToMonthly(
        bill.amountCents,
        bill.frequency ?? 'monthly',
      );
      return {'bill': bill, 'monthlyCost': monthlyCost};
    }).toList();
    
    // Sort by monthly cost descending
    billsWithMonthlyCost.sort((a, b) {
      return (b['monthlyCost'] as int).compareTo(a['monthlyCost'] as int);
    });
    
    // Return top N bills
    return billsWithMonthlyCost
        .take(limit)
        .map((item) => item['bill'] as BillEntity)
        .toList();
  }

  /// Get bills by provider
  /// 
  /// Groups bills by provider name
  Future<Map<String, List<BillEntity>>> getBillsByProvider() async {
    final allBills = await _database.billsDao.getActiveBills();
    
    final Map<String, List<BillEntity>> grouped = {};
    
    for (final bill in allBills) {
      final provider = bill.provider ?? 'Unknown';
      grouped.putIfAbsent(provider, () => []).add(bill);
    }
    
    return grouped;
  }

  /// Convert amount to monthly equivalent
  /// 
  /// Helper method for consistent frequency conversion
  int _convertToMonthly(int amountCents, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'monthly':
        return amountCents;
      case 'quarterly':
        return (amountCents / 3).round();
      case 'annual':
      case 'yearly':
        return (amountCents / 12).round();
      case 'weekly':
        return (amountCents * 52 / 12).round();
      default:
        return amountCents;
    }
  }
}

