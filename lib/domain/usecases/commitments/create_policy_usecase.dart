import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/entity_validators.dart';

class CreatePolicyUseCase {
  final AppDatabase _database;
  CreatePolicyUseCase(this._database);

  Future<int> call({
    required String policyName,
    required String policyNumber,
    required String policyType,
    required String provider,
    required int premiumAmountCents,
    required String premiumFrequency,
    required DateTime startDate,
    required DateTime renewalDate,
    DateTime? expiryDate,
    String? coverageType,
    int? coverageAmountCents,
    int? excessAmountCents,
    bool autoRenew = true,
    String currency = 'GBP',
    bool generateReminder = true,
  }) async {
    EntityValidators.validatePolicy(
      policyName: policyName,
      policyNumber: policyNumber,
      policyType: policyType,
      premiumAmountCents: premiumAmountCents,
      renewalDate: renewalDate,
      startDate: startDate,
      expiryDate: expiryDate,
      coverageAmountCents: coverageAmountCents,
    );

    return await _database.transaction(() async {
      final policyId = await _database.policiesDao.createPolicy(
        PoliciesCompanion.insert(
          policyName: policyName,
          policyNumber: policyNumber,
          policyType: policyType,
          provider: provider,
          premiumAmountCents: premiumAmountCents,
          premiumFrequency: premiumFrequency,
          startDate: startDate,
          renewalDate: renewalDate,
          expiryDate: Value(expiryDate),
          coverageType: Value(coverageType),
          coverageAmountCents: Value(coverageAmountCents),
          excessAmountCents: Value(excessAmountCents),
          autoRenew: Value(autoRenew),
          currency: Value(currency),
          status: const Value('active'),
        ),
      );

      if (generateReminder) {
        await _generatePolicyReminder(
            policyId: policyId, renewalDate: renewalDate);
      }

      return policyId;
    });
  }

  Future<void> _generatePolicyReminder({
    required int policyId,
    required DateTime renewalDate,
  }) async {
    const leadIn = 14;
    final firesAt = renewalDate.subtract(const Duration(days: leadIn));
    if (firesAt.isBefore(DateTime.now())) return;

    final existing =
        await _database.remindersDao.getForSource('policy', policyId);
    final dup = existing.any((r) =>
        r.triggerTypeId == 'renewal_date' && r.state != 'completed');
    if (dup) return;

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
