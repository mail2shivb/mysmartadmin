import '../../../data/local/app_database.dart';

/// Use case for retrieving active subscriptions
///
/// Fetches all active subscriptions with optional filtering
class GetActiveSubscriptionsUseCase {
  final AppDatabase _database;

  GetActiveSubscriptionsUseCase(this._database);

  /// Get all active subscriptions
  /// 
  /// Returns list of active subscriptions sorted by renewal date
  Future<List<SubscriptionEntity>> call({
    String? category,
    bool? autoRenew,
  }) async {
    // Get all active subscriptions
    final activeSubscriptions = await _database.subscriptionsDao.getActiveSubscriptions();

    // Apply filters
    var filteredSubscriptions = activeSubscriptions;

    if (category != null && category.trim().isNotEmpty) {
      filteredSubscriptions = filteredSubscriptions.where((s) => s.category == category).toList();
    }

    if (autoRenew != null) {
      filteredSubscriptions = filteredSubscriptions.where((s) => s.autoRenew == autoRenew).toList();
    }

    // Sort by renewal date
    filteredSubscriptions.sort((a, b) => a.renewalDate.compareTo(b.renewalDate));

    return filteredSubscriptions;
  }

  /// Get subscriptions by category
  Future<List<SubscriptionEntity>> getByCategory(String category) async {
    if (category.trim().isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }

    return await _database.subscriptionsDao.getSubscriptionsByCategory(category);
  }

  /// Get trial subscriptions
  Future<List<SubscriptionEntity>> getTrials() async {
    return await _database.subscriptionsDao.getTrialSubscriptions();
  }

  /// Get subscriptions renewing within specified days
  Future<List<SubscriptionEntity>> getRenewingSoon(int days) async {
    if (days < 0) {
      throw ArgumentError('Days must be non-negative');
    }

    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return await _database.subscriptionsDao.getSubscriptionsRenewingBetween(now, endDate);
  }

  /// Get subscriptions without auto-renew
  Future<List<SubscriptionEntity>> getManualRenewals() async {
    final activeSubscriptions = await _database.subscriptionsDao.getActiveSubscriptions();
    return activeSubscriptions.where((s) => !s.autoRenew).toList();
  }
}

