import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/money.dart';
import '../../validation/date_rules.dart';
import '../../validation/versioning_rules.dart';

/// Use case for updating an existing subscription
///
/// Creates new version and optionally updates reminders
class UpdateSubscriptionUseCase {
  final AppDatabase _database;

  UpdateSubscriptionUseCase(this._database);

  /// Update subscription and create new version
  /// 
  /// Returns the ID of the new subscription version
  Future<int> call({
    required int subscriptionId,
    String? name,
    String? description,
    String? category,
    String? provider,
    int? amountCents,
    String? billingFrequency,
    DateTime? renewalDate,
    bool? autoRenew,
    String? status,
    DateTime? cancellationDate,
    bool updateReminder = true,
  }) async {
    if (subscriptionId <= 0) {
      throw ArgumentError('Invalid subscription ID');
    }

    // Verify subscription exists
    final existingSubscription = await _database.subscriptionsDao.getSubscriptionById(subscriptionId);
    if (existingSubscription == null) {
      throw StateError('Subscription with ID $subscriptionId not found');
    }

    // Validate amount using centralized money validator
    Money.validateNullablePositiveAmount(amountCents);

    // Validate billing frequency if provided
    if (billingFrequency != null && !['monthly', 'annual'].contains(billingFrequency)) {
      throw ArgumentError('Billing frequency must be either "monthly" or "annual"');
    }

    // Validate renewal date if provided
    if (renewalDate != null) {
      DateRules.validateFutureDate(renewalDate);
      DateRules.validateReasonableFutureDate(renewalDate);
    }

    // Validate cancellation date relationship
    if (cancellationDate != null) {
      DateRules.validateDateRange(existingSubscription.startDate, cancellationDate);
    }

    // Validate versioning rules
    VersioningRules.validateVersionNumber(existingSubscription.version);
    VersioningRules.validatePreviousVersionReference(
      existingSubscription.version + 1,
      subscriptionId,
    );

    // Build updates companion
    final updates = SubscriptionsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      provider: provider != null ? Value(provider) : const Value.absent(),
      amountCents: amountCents != null ? Value(amountCents) : const Value.absent(),
      billingFrequency: billingFrequency != null ? Value(billingFrequency) : const Value.absent(),
      renewalDate: renewalDate != null ? Value(renewalDate) : const Value.absent(),
      autoRenew: autoRenew != null ? Value(autoRenew) : const Value.absent(),
      status: status != null ? Value(status) : const Value.absent(),
      cancellationDate: cancellationDate != null ? Value(cancellationDate) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Create new version
      final newVersionId = await _database.subscriptionsDao.createSubscriptionVersion(
        subscriptionId,
        updates,
      );

      // Update reminder if renewal date changed and updateReminder is true
      if (updateReminder && renewalDate != null) {
        await _updateSubscriptionReminder(
          subscriptionId: subscriptionId,
          subscriptionName: name ?? existingSubscription.name,
          renewalDate: renewalDate,
        );
      }

      return newVersionId;
    });
  }

  /// Update or create reminder for subscription
  Future<void> _updateSubscriptionReminder({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime renewalDate,
  }) async {
    // Calculate reminder date (7 days before renewal)
    final reminderDate = renewalDate.subtract(const Duration(days: 7));
    
    // Only create/update reminder if it's in the future
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    // Find existing pending reminder for this subscription using entity-based detection
    final allReminders = await _database.remindersDao.getPendingReminders();
    final existingReminder = allReminders.where(
      (r) => r.description != null &&
             r.description!.contains('[ENTITY:subscription:$subscriptionId]') &&
             r.reminderType == 'subscription_renewal',
    ).firstOrNull;

    if (existingReminder != null) {
      // Update existing reminder date
      await _database.remindersDao.updateReminderDate(
        existingReminder.id,
        reminderDate,
      );
    } else {
      // Create new reminder with entity identifier
      await _database.remindersDao.createReminder(
        RemindersCompanion.insert(
          title: 'Subscription renewal: $subscriptionName',
          description: Value('[ENTITY:subscription:$subscriptionId] Renews on ${renewalDate.toIso8601String().split('T')[0]}'),
          reminderDate: reminderDate,
          reminderType: 'subscription_renewal',
          status: const Value('pending'),
        ),
      );
    }
  }
}

