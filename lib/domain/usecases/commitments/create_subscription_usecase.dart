import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/entity_validators.dart';

/// Use case for creating a new subscription
///
/// Creates subscription and optionally generates a reminder for renewal
class CreateSubscriptionUseCase {
  final AppDatabase _database;

  CreateSubscriptionUseCase(this._database);

  /// Create a new subscription with optional reminder generation
  /// 
  /// Returns the ID of the newly created subscription
  Future<int> call({
    required String name,
    required String category,
    required int amountCents,
    required String billingFrequency,
    required DateTime startDate,
    required DateTime renewalDate,
    String? description,
    String? provider,
    bool autoRenew = true,
    bool isTrial = false,
    DateTime? trialEndDate,
    String currency = 'GBP',
    bool generateReminder = true,
  }) async {
    // Use centralized entity validator
    EntityValidators.validateSubscription(
      name: name,
      category: category,
      amountCents: amountCents,
      billingFrequency: billingFrequency,
      startDate: startDate,
      renewalDate: renewalDate,
      isTrial: isTrial,
      trialEndDate: trialEndDate,
    );

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Create the subscription
      final subscriptionId = await _database.subscriptionsDao.createSubscription(
        SubscriptionsCompanion.insert(
          name: name,
          category: category,
          amountCents: amountCents,
          billingFrequency: billingFrequency,
          startDate: startDate,
          renewalDate: renewalDate,
          description: Value(description),
          provider: Value(provider),
          autoRenew: Value(autoRenew),
          isTrial: Value(isTrial),
          trialEndDate: Value(trialEndDate),
          currency: Value(currency),
          status: Value(isTrial ? 'trial' : 'active'),
        ),
      );

      // Auto-generate reminder if requested
      if (generateReminder) {
        final reminderDate = isTrial && trialEndDate != null ? trialEndDate : renewalDate;
        await _generateSubscriptionReminder(
          subscriptionId: subscriptionId,
          subscriptionName: name,
          renewalDate: reminderDate,
          isTrial: isTrial,
        );
      }

      return subscriptionId;
    });
  }

  /// Generate reminder for subscription renewal
  Future<void> _generateSubscriptionReminder({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime renewalDate,
    required bool isTrial,
  }) async {
    // Calculate reminder date (7 days before renewal for annual, 3 days for monthly/trial)
    final reminderDate = renewalDate.subtract(Duration(days: isTrial ? 2 : 7));
    
    // Only create reminder if it's in the future
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    // Check if reminder already exists using entity-based detection
    final existingReminders = await _database.remindersDao.getAllReminders();
    final duplicateExists = existingReminders.any(
      (r) => r.description != null &&
             r.description!.contains('[ENTITY:subscription:$subscriptionId]') &&
             r.reminderType == 'subscription_renewal' && 
             r.status != 'completed',
    );

    if (duplicateExists) {
      return;
    }

    // Create the reminder with entity identifier
    final reminderType = isTrial ? 'Trial ending' : 'Subscription renewal';
    await _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        entityType: 'subscription',
        entityId: subscriptionId,
        title: '$reminderType: $subscriptionName',
        description: Value('[ENTITY:subscription:$subscriptionId] Renews on ${renewalDate.toIso8601String().split('T')[0]}'),
        reminderDate: reminderDate,
        reminderType: 'subscription_renewal',
        status: const Value('pending'),
      ),
    );
  }
}

