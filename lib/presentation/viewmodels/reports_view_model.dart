// B12 STATUS: IMPLEMENTED

import '../../domain/reports/reports_repository.dart';
import '../../data/local/app_database.dart';

/// Reports ViewModel
///
/// Thin adapter for reports/analytics UI to fetch bill and subscription data.
/// Acts as a façade for generic report queries.
/// Calls ReportsRepository and returns data directly.
/// Contains NO business logic, NO caching, NO mutation.
class ReportsViewModel {
  final ReportsRepository _repository;

  ReportsViewModel(this._repository);

  // ============================================================
  // BILL REPORTS
  // ============================================================

  /// Load total monthly bill costs
  ///
  /// Returns sum of all active recurring bills normalized to monthly amounts.
  Future<int> loadBillsMonthlyTotal() async {
    return await _repository.getBillsMonthlyTotal();
  }

  /// Load bills grouped by category with monthly totals
  ///
  /// Returns map: category → monthly cost
  Future<Map<String, int>> loadBillsMonthlyCostsByCategory() async {
    return await _repository.getBillsMonthlyCostsByCategory();
  }

  /// Load bills due within next N days
  ///
  /// [daysAhead] defaults to 7 days
  Future<List<BillEntity>> loadBillsDueSoon({int daysAhead = 7}) async {
    return await _repository.getBillsDueSoon(daysAhead: daysAhead);
  }

  /// Load overdue bills
  ///
  /// Returns bills with nextDueDate in the past.
  Future<List<BillEntity>> loadOverdueBills() async {
    return await _repository.getOverdueBills();
  }

  /// Count active bills
  ///
  /// Returns total count of active (not deleted) bills.
  Future<int> countActiveBills() async {
    return await _repository.countActiveBills();
  }

  /// Load highest cost bills
  ///
  /// Returns top N bills by monthly cost.
  /// [limit] defaults to 5
  Future<List<BillEntity>> loadHighestCostBills({int limit = 5}) async {
    return await _repository.getHighestCostBills(limit: limit);
  }

  /// Load bills grouped by provider
  ///
  /// Returns map: provider → list of bills
  Future<Map<String, List<BillEntity>>> loadBillsByProvider() async {
    return await _repository.getBillsByProvider();
  }

  // ============================================================
  // SUBSCRIPTION REPORTS
  // ============================================================

  /// Load total monthly subscription costs
  ///
  /// Returns sum of all active subscriptions normalized to monthly amounts.
  Future<int> loadSubscriptionsMonthlyTotal() async {
    return await _repository.getSubscriptionsMonthlyTotal();
  }

  /// Load subscriptions grouped by category with monthly totals
  ///
  /// Returns map: category → monthly cost
  Future<Map<String, int>> loadSubscriptionsMonthlyCostsByCategory() async {
    return await _repository.getSubscriptionsMonthlyCostsByCategory();
  }

  /// Load subscriptions renewing within next N days
  ///
  /// [daysAhead] defaults to 7 days
  Future<List<SubscriptionEntity>> loadSubscriptionsRenewingSoon({
    int daysAhead = 7,
  }) async {
    return await _repository.getSubscriptionsRenewingSoon(daysAhead: daysAhead);
  }

  /// Load trials ending within next N days
  ///
  /// [daysAhead] defaults to 7 days
  Future<List<SubscriptionEntity>> loadTrialsEndingSoon({
    int daysAhead = 7,
  }) async {
    return await _repository.getTrialsEndingSoon(daysAhead: daysAhead);
  }

  /// Count active subscriptions
  ///
  /// Returns total count of active (not deleted) subscriptions.
  Future<int> countActiveSubscriptions() async {
    return await _repository.countActiveSubscriptions();
  }

  /// Load highest cost subscriptions
  ///
  /// Returns top N subscriptions by monthly cost.
  /// [limit] defaults to 5
  Future<List<SubscriptionEntity>> loadHighestCostSubscriptions({
    int limit = 5,
  }) async {
    return await _repository.getHighestCostSubscriptions(limit: limit);
  }

  /// Load subscriptions grouped by provider
  ///
  /// Returns map: provider → list of subscriptions
  Future<Map<String, List<SubscriptionEntity>>> loadSubscriptionsByProvider() async {
    return await _repository.getSubscriptionsByProvider();
  }

  /// Load unused subscriptions
  ///
  /// Returns subscriptions with no recent usage.
  /// [days] defaults to 90 days
  Future<List<SubscriptionEntity>> loadUnusedSubscriptions({int days = 90}) async {
    return await _repository.getUnusedSubscriptions(days: days);
  }
}

