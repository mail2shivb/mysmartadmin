// B11.3 STATUS: IMPLEMENTED

import '../../data/local/app_database.dart';

/// Subscription-specific reports service
/// 
/// Read-only queries for subscription analytics and insights
class SubscriptionReports {
  final AppDatabase _database;

  SubscriptionReports(this._database);

  /// Get total monthly subscription costs
  /// 
  /// Uses version-aware filtering (latest versions only)
  Future<int> getMonthlyTotal() async {
    return await _database.subscriptionsDao.calculateMonthlyTotal();
  }

  /// Get subscriptions by category with totals
  /// 
  /// Returns monthly costs grouped by category
  Future<Map<String, int>> getMonthlyCostsByCategory() async {
    final activeSubscriptions = await _database.subscriptionsDao.getActiveSubscriptions();
    
    final Map<String, int> categoryTotals = {};
    
    for (final subscription in activeSubscriptions) {
      int monthlyAmount = _convertToMonthly(
        subscription.amountCents,
        subscription.billingFrequency,
      );
      
      categoryTotals[subscription.category] = 
          (categoryTotals[subscription.category] ?? 0) + monthlyAmount;
    }
    
    return categoryTotals;
  }

  /// Get subscriptions renewing within next N days
  Future<List<SubscriptionEntity>> getSubscriptionsRenewingSoon({
    int daysAhead = 7,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));
    
    return await _database.subscriptionsDao.getSubscriptionsRenewingBetween(
      now,
      endDate,
    );
  }

  /// Get trial subscriptions ending soon
  /// 
  /// Returns subscriptions in trial status with trialEndDate within N days
  Future<List<SubscriptionEntity>> getTrialsEndingSoon({int daysAhead = 7}) async {
    final trialSubscriptions = await _database.subscriptionsDao.getTrialSubscriptions();
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));
    
    return trialSubscriptions.where((sub) {
      return sub.trialEndDate != null &&
             sub.trialEndDate!.isAfter(now) &&
             sub.trialEndDate!.isBefore(endDate);
    }).toList();
  }

  /// Count active subscriptions
  Future<int> countActiveSubscriptions() async {
    return await _database.subscriptionsDao.countActiveSubscriptions();
  }

  /// Get highest cost subscriptions (top N)
  /// 
  /// Returns subscriptions sorted by monthly cost descending
  Future<List<SubscriptionEntity>> getHighestCostSubscriptions({
    int limit = 5,
  }) async {
    final activeSubscriptions = await _database.subscriptionsDao.getActiveSubscriptions();
    
    // Calculate monthly equivalent for each subscription
    final subscriptionsWithMonthlyCost = activeSubscriptions.map((sub) {
      final monthlyCost = _convertToMonthly(
        sub.amountCents,
        sub.billingFrequency,
      );
      return {'subscription': sub, 'monthlyCost': monthlyCost};
    }).toList();
    
    // Sort by monthly cost descending
    subscriptionsWithMonthlyCost.sort((a, b) {
      return (b['monthlyCost'] as int).compareTo(a['monthlyCost'] as int);
    });
    
    // Return top N subscriptions
    return subscriptionsWithMonthlyCost
        .take(limit)
        .map((item) => item['subscription'] as SubscriptionEntity)
        .toList();
  }

  /// Get subscriptions by provider
  /// 
  /// Groups subscriptions by provider name
  Future<Map<String, List<SubscriptionEntity>>> getSubscriptionsByProvider() async {
    final allSubscriptions = await _database.subscriptionsDao.getActiveSubscriptions();
    
    final Map<String, List<SubscriptionEntity>> grouped = {};
    
    for (final subscription in allSubscriptions) {
      final provider = subscription.provider ?? 'Unknown';
      grouped.putIfAbsent(provider, () => []).add(subscription);
    }
    
    return grouped;
  }

  /// Get unused subscriptions (not used in N days)
  /// 
  /// Returns subscriptions where lastUsedDate is older than N days or null
  Future<List<SubscriptionEntity>> getUnusedSubscriptions({int days = 90}) async {
    return await _database.subscriptionsDao.getUnusedSubscriptions(days);
  }

  /// Convert amount to monthly equivalent
  /// 
  /// Helper method for consistent frequency conversion
  int _convertToMonthly(int amountCents, String billingFrequency) {
    switch (billingFrequency.toLowerCase()) {
      case 'monthly':
        return amountCents;
      case 'annual':
      case 'yearly':
        return (amountCents / 12).round();
      case 'quarterly':
        return (amountCents / 3).round();
      default:
        return amountCents;
    }
  }
}

