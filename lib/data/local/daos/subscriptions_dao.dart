import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/subscriptions.dart';

part 'subscriptions_dao.g.dart';

/// Data Access Object for Subscriptions
/// 
/// Manages digital and lifestyle subscriptions
@DriftAccessor(tables: [Subscriptions])
class SubscriptionsDao extends DatabaseAccessor<AppDatabase> with _$SubscriptionsDaoMixin {
  SubscriptionsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new subscription
  Future<int> createSubscription(SubscriptionsCompanion subscription) {
    return into(subscriptions).insert(subscription);
  }

  /// Create multiple subscriptions
  Future<void> createSubscriptions(List<SubscriptionsCompanion> subscriptionList) async {
    await batch((batch) {
      batch.insertAll(subscriptions, subscriptionList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a subscription by ID
  Future<SubscriptionEntity?> getSubscriptionById(int id) {
    return (select(subscriptions)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all subscriptions
  Future<List<SubscriptionEntity>> getAllSubscriptions() {
    return (select(subscriptions)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get subscriptions by category
  Future<List<SubscriptionEntity>> getSubscriptionsByCategory(String category) {
    return (select(subscriptions)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get subscriptions by status
  Future<List<SubscriptionEntity>> getSubscriptionsByStatus(String status) {
    return (select(subscriptions)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get active subscriptions
  Future<List<SubscriptionEntity>> getActiveSubscriptions() {
    return getSubscriptionsByStatus('active');
  }

  /// Get trial subscriptions
  Future<List<SubscriptionEntity>> getTrialSubscriptions() {
    return (select(subscriptions)
          ..where((t) => t.isTrial.equals(true))
          ..where((t) => t.status.equals('trial'))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.trialEndDate)]))
        .get();
  }

  /// Get subscriptions renewing within a date range
  Future<List<SubscriptionEntity>> getSubscriptionsRenewingBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(subscriptions)
          ..where((t) => t.renewalDate.isBetweenValues(start, end))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get subscriptions renewing this month
  Future<List<SubscriptionEntity>> getSubscriptionsRenewingThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getSubscriptionsRenewingBetween(startOfMonth, endOfMonth);
  }

  /// Get subscriptions by provider
  Future<List<SubscriptionEntity>> getSubscriptionsByProvider(String provider) {
    return (select(subscriptions)
          ..where((t) => t.provider.equals(provider))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull()))
        .get();
  }

  /// Get subscriptions with auto-renew enabled
  Future<List<SubscriptionEntity>> getAutoRenewSubscriptions() {
    return (select(subscriptions)
          ..where((t) => t.autoRenew.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull()))
        .get();
  }

  /// Get unused subscriptions (no recent usage)
  Future<List<SubscriptionEntity>> getUnusedSubscriptions(int daysSinceLastUse) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysSinceLastUse));
    return (select(subscriptions)
          ..where((t) =>
              t.lastUsedDate.isSmallerThanValue(cutoffDate) |
              t.lastUsedDate.isNull())
          ..where((t) => t.status.equals('active'))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull()))
        .get();
  }

  /// Stream all subscriptions
  Stream<List<SubscriptionEntity>> watchAllSubscriptions() {
    return (select(subscriptions)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .watch();
  }

  /// Stream active subscriptions
  Stream<List<SubscriptionEntity>> watchActiveSubscriptions() {
    return (select(subscriptions)
          ..where((t) => t.status.equals('active'))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a subscription
  Future<bool> updateSubscription(SubscriptionEntity subscription) {
    return update(subscriptions).replace(subscription);
  }

  /// Update subscription status
  Future<int> updateSubscriptionStatus(int id, String status) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Cancel a subscription
  Future<int> cancelSubscription(int id, DateTime cancellationDate) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        status: const Value('cancelled'),
        cancellationDate: Value(cancellationDate),
        autoRenew: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update last used date
  Future<int> updateLastUsed(int id) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        lastUsedDate: Value(DateTime.now()),
        usageCount: Value(1), // This will need custom logic to increment
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Increment usage count
  Future<void> incrementUsageCount(int id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      await (update(subscriptions)..where((t) => t.id.equals(id))).write(
        SubscriptionsCompanion(
          usageCount: Value(subscription.usageCount + 1),
          lastUsedDate: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Update renewal date
  Future<int> updateRenewalDate(int id, DateTime renewalDate) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        renewalDate: Value(renewalDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggle auto-renew
  Future<int> toggleAutoRenew(int id, bool autoRenew) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        autoRenew: Value(autoRenew),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// End trial and activate subscription
  Future<int> endTrial(int id) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        status: const Value('active'),
        isTrial: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a subscription
  Future<int> softDeleteSubscription(int id) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      SubscriptionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a subscription
  Future<int> hardDeleteSubscription(int id) {
    return (delete(subscriptions)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted subscription
  Future<int> restoreSubscription(int id) {
    return (update(subscriptions)..where((t) => t.id.equals(id))).write(
      const SubscriptionsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total monthly subscription cost (in cents)
  Future<int> calculateMonthlyTotal() async {
    final activeSubscriptions = await getActiveSubscriptions();
    int total = 0;

    for (final subscription in activeSubscriptions) {
      // Convert to monthly equivalent
      switch (subscription.billingFrequency) {
        case 'monthly':
          total += subscription.amountCents;
          break;
        case 'annual':
          total += (subscription.amountCents / 12).round();
          break;
      }
    }

    return total;
  }

  /// Calculate annual subscription cost (in cents)
  Future<int> calculateAnnualTotal() async {
    final activeSubscriptions = await getActiveSubscriptions();
    int total = 0;

    for (final subscription in activeSubscriptions) {
      // Convert to annual equivalent
      switch (subscription.billingFrequency) {
        case 'monthly':
          total += subscription.amountCents * 12;
          break;
        case 'annual':
          total += subscription.amountCents;
          break;
      }
    }

    return total;
  }

  /// Count subscriptions by category
  Future<int> countSubscriptionsByCategory(String category) async {
    final query = selectOnly(subscriptions)
      ..addColumns([subscriptions.id.count()])
      ..where(subscriptions.category.equals(category))
      ..where(subscriptions.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(subscriptions.id.count()) ?? 0;
  }

  /// Count active subscriptions
  Future<int> countActiveSubscriptions() async {
    final query = selectOnly(subscriptions)
      ..addColumns([subscriptions.id.count()])
      ..where(subscriptions.status.equals('active'))
      ..where(subscriptions.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(subscriptions.id.count()) ?? 0;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get subscription versions
  Future<List<SubscriptionEntity>> getSubscriptionVersions(int subscriptionId) {
    return (select(subscriptions)
          ..where((t) =>
              t.id.equals(subscriptionId) |
              t.previousVersionId.equals(subscriptionId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of a subscription
  Future<int> createSubscriptionVersion(
    int existingSubscriptionId,
    SubscriptionsCompanion updates,
  ) async {
    final existing = await getSubscriptionById(existingSubscriptionId);
    if (existing == null) throw Exception('Subscription not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingSubscriptionId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(subscriptions).insert(newVersion);
  }
}

