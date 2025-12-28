import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';
import '../../validation/money.dart';

/// Use case for renewing an existing policy
///
/// Updates renewal date and optionally premium, then updates the linked reminder
class RenewPolicyUseCase {
  final AppDatabase _database;

  RenewPolicyUseCase(this._database);

  /// Renew policy with new renewal date
  /// 
  /// Returns the number of rows affected (1 if successful)
  Future<int> call({
    required int policyId,
    required DateTime newRenewalDate,
    int? newPremiumAmountCents,
    bool updateReminder = true,
  }) async {
    if (policyId <= 0) {
      throw ArgumentError('Invalid policy ID');
    }

    // Verify policy exists
    final existingPolicy = await _database.policiesDao.getPolicyById(policyId);
    if (existingPolicy == null) {
      throw StateError('Policy with ID $policyId not found');
    }

    // Validate new renewal date
    DateRules.validateFutureDate(newRenewalDate);
    DateRules.validateReasonableFutureDate(newRenewalDate);

    // Validate premium if provided
    Money.validateNullablePositiveAmount(newPremiumAmountCents);

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Update the policy renewal date (and premium if provided)
      int rowsAffected;
      if (newPremiumAmountCents != null) {
        // Update both renewal date and premium
        rowsAffected = await (_database.update(_database.policies)
              ..where((t) => t.id.equals(policyId)))
            .write(PoliciesCompanion(
          renewalDate: Value(newRenewalDate),
          premiumAmountCents: Value(newPremiumAmountCents),
          status: const Value('active'),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        // Use DAO method for just renewal date
        rowsAffected = await _database.policiesDao.renewPolicy(
          policyId,
          newRenewalDate,
        );
      }

      // Update reminder if requested
      if (updateReminder) {
        await _updatePolicyReminder(
          policyId: policyId,
          policyName: existingPolicy.policyName,
          renewalDate: newRenewalDate,
        );
      }

      return rowsAffected;
    });
  }

  /// Update or create reminder for policy renewal
  Future<void> _updatePolicyReminder({
    required int policyId,
    required String policyName,
    required DateTime renewalDate,
  }) async {
    // Calculate reminder date (14 days before renewal)
    final reminderDate = renewalDate.subtract(const Duration(days: 14));
    
    // Only create/update reminder if it's in the future
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    // Find existing pending reminder for this policy using entity-based detection
    final allReminders = await _database.remindersDao.getPendingReminders();
    final existingReminder = allReminders.where(
      (r) => r.description != null &&
             r.description!.contains('[ENTITY:policy:$policyId]') &&
             r.reminderType == 'policy_renewal',
    ).firstOrNull;

    if (existingReminder != null) {
      // Update existing reminder date and description
      await (_database.update(_database.reminders)
            ..where((t) => t.id.equals(existingReminder.id)))
          .write(RemindersCompanion(
        reminderDate: Value(reminderDate),
        description: Value('[ENTITY:policy:$policyId] Policy renewal due on ${renewalDate.toIso8601String().split('T')[0]}'),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      // Create new reminder with entity identifier
      await _database.remindersDao.createReminder(
        RemindersCompanion.insert(
          entityType: 'policy',
          entityId: policyId,
          title: 'Policy Renewal: $policyName',
          description: Value('[ENTITY:policy:$policyId] Policy renewal due on ${renewalDate.toIso8601String().split('T')[0]}'),
          reminderDate: reminderDate,
          reminderType: 'policy_renewal',
          status: const Value('pending'),
        ),
      );
    }
  }
}

