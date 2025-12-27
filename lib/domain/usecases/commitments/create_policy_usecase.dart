import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/entity_validators.dart';

/// Use case for creating a new insurance policy
///
/// Creates policy and auto-generates a renewal reminder
class CreatePolicyUseCase {
  final AppDatabase _database;

  CreatePolicyUseCase(this._database);

  /// Create a new policy with optional reminder generation
  /// 
  /// Returns the ID of the newly created policy
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
    // Use centralized entity validator
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

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Create the policy
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

      // Auto-generate reminder if requested
      if (generateReminder) {
        await _generatePolicyReminder(
          policyId: policyId,
          policyName: policyName,
          renewalDate: renewalDate,
        );
      }

      return policyId;
    });
  }

  /// Generate reminder for policy renewal date
  Future<void> _generatePolicyReminder({
    required int policyId,
    required String policyName,
    required DateTime renewalDate,
  }) async {
    // Calculate reminder date (14 days before renewal)
    final reminderDate = renewalDate.subtract(const Duration(days: 14));
    
    // Only create reminder if it's in the future
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    // Check if reminder already exists for this policy using entity-based detection
    final existingReminders = await _database.remindersDao.getAllReminders();
    final duplicateExists = existingReminders.any(
      (r) => r.description != null &&
             r.description!.contains('[ENTITY:policy:$policyId]') &&
             r.reminderType == 'policy_renewal' && 
             r.status != 'completed',
    );

    if (duplicateExists) {
      return;
    }

    // Create the reminder with entity identifier in description
    await _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        title: 'Policy Renewal: $policyName',
        description: Value('[ENTITY:policy:$policyId] Policy renewal due on ${renewalDate.toIso8601String().split('T')[0]}'),
        reminderDate: reminderDate,
        reminderType: 'policy_renewal',
        status: const Value('pending'),
      ),
    );
  }
}

