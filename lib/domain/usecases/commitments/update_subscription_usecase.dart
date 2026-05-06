import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/money.dart';
import '../../validation/date_rules.dart';
import '../../validation/versioning_rules.dart';

class UpdateSubscriptionUseCase {
  final AppDatabase _database;
  UpdateSubscriptionUseCase(this._database);

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
    if (subscriptionId <= 0) throw ArgumentError('Invalid subscription ID');

    final existing =
        await _database.subscriptionsDao.getSubscriptionById(subscriptionId);
    if (existing == null) throw StateError('Subscription $subscriptionId not found');

    Money.validateNullablePositiveAmount(amountCents);
    if (billingFrequency != null &&
        !['monthly', 'annual'].contains(billingFrequency)) {
      throw ArgumentError('Billing frequency must be monthly or annual');
    }
    if (renewalDate != null) {
      DateRules.validateFutureDate(renewalDate);
      DateRules.validateReasonableFutureDate(renewalDate);
    }
    if (cancellationDate != null) {
      DateRules.validateDateRange(existing.startDate, cancellationDate);
    }
    VersioningRules.validateVersionNumber(existing.version);
    VersioningRules.validatePreviousVersionReference(
        existing.version + 1, subscriptionId);

    final updates = SubscriptionsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      provider: provider != null ? Value(provider) : const Value.absent(),
      amountCents: amountCents != null ? Value(amountCents) : const Value.absent(),
      billingFrequency:
          billingFrequency != null ? Value(billingFrequency) : const Value.absent(),
      renewalDate: renewalDate != null ? Value(renewalDate) : const Value.absent(),
      autoRenew: autoRenew != null ? Value(autoRenew) : const Value.absent(),
      status: status != null ? Value(status) : const Value.absent(),
      cancellationDate:
          cancellationDate != null ? Value(cancellationDate) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await _database.transaction(() async {
      final newVersionId = await _database.subscriptionsDao
          .createSubscriptionVersion(subscriptionId, updates);

      if (updateReminder && renewalDate != null) {
        await _updateSubscriptionReminder(
            subscriptionId: subscriptionId, renewalDate: renewalDate);
      }

      return newVersionId;
    });
  }

  Future<void> _updateSubscriptionReminder({
    required int subscriptionId,
    required DateTime renewalDate,
  }) async {
    const leadIn = 7;
    final firesAt = renewalDate.subtract(const Duration(days: leadIn));
    if (firesAt.isBefore(DateTime.now())) return;

    final existing = await _database.remindersDao
        .getForSource('subscription', subscriptionId);
    final current = existing
        .where(
            (r) => r.triggerTypeId == 'renewal_date' && r.state == 'pending')
        .firstOrNull;

    if (current != null) {
      await _database.remindersDao
          .updateTargetDate(current.id, renewalDate, newFiresAt: firesAt);
    } else {
      await _database.remindersDao.createReminder(
        RemindersCompanion.insert(
          sourceEntityKind: 'subscription',
          sourceEntityId: subscriptionId,
          triggerTypeId: 'renewal_date',
          targetDate: renewalDate,
          leadInDaysSnapshot: const Value(leadIn),
          firesAt: firesAt,
        ),
      );
    }
  }
}
