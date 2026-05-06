import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/entity_validators.dart';

class CreateSubscriptionUseCase {
  final AppDatabase _database;
  CreateSubscriptionUseCase(this._database);

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

    return await _database.transaction(() async {
      final subscriptionId =
          await _database.subscriptionsDao.createSubscription(
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

      if (generateReminder) {
        final targetDate =
            isTrial && trialEndDate != null ? trialEndDate : renewalDate;
        await _generateSubscriptionReminder(
          subscriptionId: subscriptionId,
          targetDate: targetDate,
          isTrial: isTrial,
        );
      }

      return subscriptionId;
    });
  }

  Future<void> _generateSubscriptionReminder({
    required int subscriptionId,
    required DateTime targetDate,
    required bool isTrial,
  }) async {
    final leadIn = isTrial ? 2 : 7;
    final firesAt = targetDate.subtract(Duration(days: leadIn));
    if (firesAt.isBefore(DateTime.now())) return;

    final existing =
        await _database.remindersDao.getForSource('subscription', subscriptionId);
    final triggerType = isTrial ? 'trial_end_date' : 'renewal_date';
    final dup = existing.any(
        (r) => r.triggerTypeId == triggerType && r.state != 'completed');
    if (dup) return;

    await _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        sourceEntityKind: 'subscription',
        sourceEntityId: subscriptionId,
        triggerTypeId: triggerType,
        targetDate: targetDate,
        leadInDaysSnapshot: Value(leadIn),
        firesAt: firesAt,
      ),
    );
  }
}
