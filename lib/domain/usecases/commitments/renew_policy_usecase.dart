import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';
import '../../validation/money.dart';

class RenewPolicyUseCase {
  final AppDatabase _database;
  RenewPolicyUseCase(this._database);

  Future<int> call({
    required int policyId,
    required DateTime newRenewalDate,
    int? newPremiumAmountCents,
    bool updateReminder = true,
  }) async {
    if (policyId <= 0) throw ArgumentError('Invalid policy ID');

    final existing = await _database.policiesDao.getPolicyById(policyId);
    if (existing == null) throw StateError('Policy $policyId not found');

    DateRules.validateFutureDate(newRenewalDate);
    DateRules.validateReasonableFutureDate(newRenewalDate);
    Money.validateNullablePositiveAmount(newPremiumAmountCents);

    return await _database.transaction(() async {
      int rows;
      if (newPremiumAmountCents != null) {
        rows = await (_database.update(_database.policies)
              ..where((t) => t.id.equals(policyId)))
            .write(PoliciesCompanion(
          renewalDate: Value(newRenewalDate),
          premiumAmountCents: Value(newPremiumAmountCents),
          status: const Value('active'),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        rows = await _database.policiesDao.renewPolicy(policyId, newRenewalDate);
      }

      if (updateReminder) {
        await _updatePolicyReminder(
            policyId: policyId, renewalDate: newRenewalDate);
      }

      return rows;
    });
  }

  Future<void> _updatePolicyReminder({
    required int policyId,
    required DateTime renewalDate,
  }) async {
    const leadIn = 14;
    final firesAt = renewalDate.subtract(const Duration(days: leadIn));
    if (firesAt.isBefore(DateTime.now())) return;

    final existing =
        await _database.remindersDao.getForSource('policy', policyId);
    final current = existing
        .where((r) =>
            r.triggerTypeId == 'renewal_date' && r.state == 'pending')
        .firstOrNull;

    if (current != null) {
      await _database.remindersDao.updateTargetDate(
        current.id,
        renewalDate,
        newFiresAt: firesAt,
      );
    } else {
      await _database.remindersDao.createReminder(
        RemindersCompanion.insert(
          sourceEntityKind: 'policy',
          sourceEntityId: policyId,
          triggerTypeId: 'renewal_date',
          targetDate: renewalDate,
          leadInDaysSnapshot: const Value(leadIn),
          firesAt: firesAt,
        ),
      );
    }
  }
}
