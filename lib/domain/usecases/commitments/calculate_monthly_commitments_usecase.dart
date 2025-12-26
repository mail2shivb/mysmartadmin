import '../../../data/local/app_database.dart';

/// Use case for calculating total monthly commitments
///
/// Aggregates bills and subscriptions into monthly equivalent
class CalculateMonthlyCommitmentsUseCase {
  final AppDatabase _database;

  CalculateMonthlyCommitmentsUseCase(this._database);

  /// Calculate total monthly commitments
  /// 
  /// Returns total in cents (sum of bills + subscriptions converted to monthly)
  Future<MonthlyCommitments> call() async {
    // Get monthly bill total
    final billsTotal = await _database.billsDao.calculateMonthlyTotal();

    // Get monthly subscription total
    final subscriptionsTotal = await _database.subscriptionsDao.calculateMonthlyTotal();

    // Calculate grand total
    final grandTotal = billsTotal + subscriptionsTotal;

    return MonthlyCommitments(
      billsTotal: billsTotal,
      subscriptionsTotal: subscriptionsTotal,
      grandTotal: grandTotal,
    );
  }

  /// Get breakdown by category
  Future<CommitmentsBreakdown> getBreakdown() async {
    // Get all active bills and subscriptions
    final activeBills = await _database.billsDao.getActiveBills();
    final activeSubscriptions = await _database.subscriptionsDao.getActiveSubscriptions();

    // Build category breakdown for bills
    final Map<String, int> billsByCategory = {};
    for (final bill in activeBills) {
      if (bill.status == 'active') {
        final monthlyAmount = _convertToMonthly(bill.amountCents, bill.frequency ?? 'monthly');
        billsByCategory[bill.category] = (billsByCategory[bill.category] ?? 0) + monthlyAmount;
      }
    }

    // Build category breakdown for subscriptions
    final Map<String, int> subscriptionsByCategory = {};
    for (final subscription in activeSubscriptions) {
      final monthlyAmount = _convertToMonthly(
        subscription.amountCents,
        subscription.billingFrequency,
      );
      subscriptionsByCategory[subscription.category] = 
          (subscriptionsByCategory[subscription.category] ?? 0) + monthlyAmount;
    }

    return CommitmentsBreakdown(
      billsByCategory: billsByCategory,
      subscriptionsByCategory: subscriptionsByCategory,
    );
  }

  /// Convert amount to monthly equivalent
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
        return amountCents; // Default to monthly
    }
  }

  /// Calculate annual total
  Future<int> getAnnualTotal() async {
    final monthly = await call();
    return monthly.grandTotal * 12;
  }
}

/// Monthly commitments result
class MonthlyCommitments {
  final int billsTotal;
  final int subscriptionsTotal;
  final int grandTotal;

  MonthlyCommitments({
    required this.billsTotal,
    required this.subscriptionsTotal,
    required this.grandTotal,
  });
}

/// Commitments breakdown by category
class CommitmentsBreakdown {
  final Map<String, int> billsByCategory;
  final Map<String, int> subscriptionsByCategory;

  CommitmentsBreakdown({
    required this.billsByCategory,
    required this.subscriptionsByCategory,
  });
}

