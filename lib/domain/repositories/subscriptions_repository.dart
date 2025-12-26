import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for subscription operations
/// 
/// Thin layer above subscriptionsDao - delegates to existing DAO methods
class SubscriptionsRepository {
  final AppDatabase _database;

  SubscriptionsRepository(this._database);

  /// Add a new subscription
  Future<int> addSubscription({
    required String subscriptionName,
    required String category,
    required String provider,
    required int amountCents,
    required String billingFrequency,
    required DateTime startDate,
    required DateTime renewalDate,
    bool autoRenew = true,
    bool isTrial = false,
    DateTime? trialEndDate,
  }) {
    return _database.subscriptionsDao.createSubscription(
      SubscriptionsCompanion.insert(
        name: subscriptionName,
        category: category,
        provider: Value(provider),
        amountCents: amountCents,
        billingFrequency: billingFrequency,
        startDate: startDate,
        renewalDate: renewalDate,
        autoRenew: Value(autoRenew),
        isTrial: Value(isTrial),
        trialEndDate: Value(trialEndDate),
      ),
    );
  }

  /// Stream active subscriptions
  Stream<List<SubscriptionEntity>> watchActiveSubscriptions() {
    return _database.subscriptionsDao.watchActiveSubscriptions();
  }

  /// Get a single subscription by ID
  Future<SubscriptionEntity?> getSubscriptionById(int id) {
    return _database.subscriptionsDao.getSubscriptionById(id);
  }

  /// Calculate total monthly subscription cost (in cents)
  Future<int> calculateMonthlyTotal() {
    return _database.subscriptionsDao.calculateMonthlyTotal();
  }

  /// Soft delete a subscription (can be restored later)
  Future<int> softDeleteSubscription(int id) {
    return _database.subscriptionsDao.softDeleteSubscription(id);
  }
}

