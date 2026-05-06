import 'package:flutter/foundation.dart';

import '../data/local/app_database.dart';
import '../domain/usecases/commitments/create_policy_usecase.dart';
import '../domain/usecases/commitments/renew_policy_usecase.dart';
import '../domain/usecases/commitments/delete_policy_usecase.dart';
import '../domain/usecases/reminders/get_active_reminders_usecase.dart';

/// B10.9 Policy Lifecycle Smoke Test
/// 
/// Tests:
/// - Scenario 1: Create policy → reminder auto-created
/// - Scenario 2: Renew policy → reminder updated (no duplicates)
/// - Scenario 3: Delete policy → reminder cancelled
Future<void> runPolicySmokeTest() async {
  debugPrint('==============================');
  debugPrint('🧪 B10.9 POLICY LIFECYCLE SMOKE TEST');
  debugPrint('==============================');

  final database = AppDatabase();

  try {
    final createPolicy = CreatePolicyUseCase(database);
    final renewPolicy = RenewPolicyUseCase(database);
    final deletePolicy = DeletePolicyUseCase(database);
    final getReminders = GetActiveRemindersUseCase(database);

    /// -------------------------------
    /// SCENARIO 1 — CREATE POLICY
    /// -------------------------------
    debugPrint('');
    debugPrint('➡️ SCENARIO 1: Creating policy...');

    final policyId = await createPolicy.call(
      policyName: 'Car Insurance',
      policyNumber: 'POL-2024-001',
      policyType: 'vehicle',
      provider: 'AXA',
      premiumAmountCents: 45000, // £450.00
      premiumFrequency: 'annual',
      startDate: DateTime.now(),
      renewalDate: DateTime.now().add(const Duration(days: 365)),
      coverageType: 'comprehensive',
      autoRenew: true,
      generateReminder: true,
    );

    debugPrint('✅ Policy created with ID: $policyId');

    // Verify reminder was auto-created
    final reminders1 = await getReminders.call();
    final policyReminders1 = reminders1.where(
      (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
    ).toList();

    debugPrint('📌 Active reminders for policy: ${policyReminders1.length}');
    for (final r in policyReminders1) {
      debugPrint('🔔 Reminder → id=${r.id}, type=${r.triggerTypeId}, state=${r.state}');
    }

    if (policyReminders1.isEmpty) {
      throw StateError('FAIL: No reminder created for policy');
    }
    if (policyReminders1.length > 1) {
      throw StateError('FAIL: Duplicate reminders created');
    }

    final originalReminderId = policyReminders1.first.id;
    debugPrint('✅ SCENARIO 1 PASSED: Reminder auto-created (id=$originalReminderId)');

    /// -------------------------------
    /// SCENARIO 2 — RENEW POLICY
    /// -------------------------------
    debugPrint('');
    debugPrint('➡️ SCENARIO 2: Renewing policy (new date + premium)...');

    final newRenewalDate = DateTime.now().add(const Duration(days: 730)); // 2 years
    await renewPolicy.call(
      policyId: policyId,
      newRenewalDate: newRenewalDate,
      newPremiumAmountCents: 48000, // £480.00 (price increase)
      updateReminder: true,
    );

    debugPrint('✅ Policy renewed');

    // Verify reminder was updated, not duplicated
    final reminders2 = await getReminders.call();
    final policyReminders2 = reminders2.where(
      (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
    ).toList();

    debugPrint('🔁 Active reminders after renewal: ${policyReminders2.length}');
    for (final r in policyReminders2) {
      debugPrint('🔔 Reminder → id=${r.id}, type=${r.triggerTypeId}, date=${r.firesAt.toIso8601String().split('T')[0]}');
    }

    if (policyReminders2.length != 1) {
      throw StateError('FAIL: Expected 1 reminder after renewal, got ${policyReminders2.length}');
    }

    final updatedReminder = policyReminders2.first;
    // Verify reminder date was updated (should be 14 days before new renewal date)
    final expectedReminderDate = newRenewalDate.subtract(const Duration(days: 14));
    final dateDiff = updatedReminder.firesAt.difference(expectedReminderDate).inDays.abs();
    if (dateDiff > 1) {
      throw StateError('FAIL: Reminder date not updated correctly');
    }

    debugPrint('✅ SCENARIO 2 PASSED: Reminder updated, no duplicates');

    /// -------------------------------
    /// SCENARIO 3 — DELETE POLICY
    /// -------------------------------
    debugPrint('');
    debugPrint('➡️ SCENARIO 3: Deleting policy...');

    final deleted = await deletePolicy.call(policyId);
    debugPrint('🗑️ Policy soft-deleted: $deleted');

    // Verify reminder was cancelled (not in active reminders)
    final reminders3 = await getReminders.call();
    final policyReminders3 = reminders3.where(
      (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
    ).toList();

    debugPrint('❌ Active reminders after delete: ${policyReminders3.length}');

    if (policyReminders3.isNotEmpty) {
      throw StateError('FAIL: Reminder not cancelled after policy delete');
    }

    debugPrint('✅ SCENARIO 3 PASSED: Reminder cancelled');

    debugPrint('');
    debugPrint('==============================');
    debugPrint('✅ B10.9 POLICY SMOKE TEST PASSED');
    debugPrint('==============================');
  } catch (e, stack) {
    debugPrint('');
    debugPrint('❌ POLICY SMOKE TEST FAILED');
    debugPrint(e.toString());
    debugPrint(stack.toString());
  } finally {
    await database.close();
  }
}

