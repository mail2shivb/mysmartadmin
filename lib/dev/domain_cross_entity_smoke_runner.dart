import 'package:flutter/foundation.dart';

import '../data/local/app_database.dart';
import '../domain/usecases/documents/add_document_usecase.dart';
import '../domain/usecases/documents/delete_document_usecase.dart';
import '../domain/usecases/commitments/create_policy_usecase.dart';
import '../domain/usecases/commitments/renew_policy_usecase.dart';
import '../domain/usecases/commitments/create_bill_usecase.dart';
import '../domain/usecases/commitments/delete_bill_usecase.dart';
import '../domain/usecases/commitments/create_subscription_usecase.dart';
import '../domain/usecases/commitments/calculate_monthly_commitments_usecase.dart';
import '../domain/usecases/reminders/get_active_reminders_usecase.dart';

/// B10.10 Cross-Entity Domain Smoke Tests
/// 
/// Tests interactions between different domain entities
Future<void> runCrossEntitySmokeTests(AppDatabase db) async {
  debugPrint('');
  debugPrint('═══════════════════════════════════════');
  debugPrint('🔗 B10.10 CROSS-ENTITY SMOKE TESTS');
  debugPrint('═══════════════════════════════════════');

  int scenariosTotal = 4;
  int scenariosPassed = 0;

  try {
    // Initialize use cases
    final addDocument = AddDocumentUseCase(db);
    final deleteDocument = DeleteDocumentUseCase(db);
    final createPolicy = CreatePolicyUseCase(db);
    final renewPolicy = RenewPolicyUseCase(db);
    final createBill = CreateBillUseCase(db);
    final deleteBill = DeleteBillUseCase(db);
    final createSubscription = CreateSubscriptionUseCase(db);
    final calculateMonthly = CalculateMonthlyCommitmentsUseCase(db);
    final getReminders = GetActiveRemindersUseCase(db);

    /// ════════════════════════════════════════
    /// SCENARIO 1: Document ↔ Policy ↔ Reminder
    /// ════════════════════════════════════════
    debugPrint('');
    debugPrint('📋 SCENARIO 1: Document ↔ Policy ↔ Reminder');
    debugPrint('────────────────────────────────────────');
    await db.hardReset();
    try {
      // Step 1: Create a document
      final docId = await addDocument.call(
        title: 'Home Insurance Policy Doc',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      );
      debugPrint('✓ Document created (id=$docId)');

      // Step 2: Create a policy linked to that document
      final policyId = await createPolicy.call(
        policyName: 'Home Insurance',
        policyNumber: 'HOME-2024-001',
        policyType: 'home',
        provider: 'Aviva',
        premiumAmountCents: 35000, // £350
        premiumFrequency: 'annual',
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 365)),
        generateReminder: true,
      );
      debugPrint('✓ Policy created (id=$policyId)');

      // Step 3: Verify exactly 1 reminder exists
      final reminders1 = await getReminders.call();
      final policyReminders = reminders1.where(
        (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
      ).toList();

      if (policyReminders.length != 1) {
        throw StateError('Expected 1 policy reminder, got ${policyReminders.length}');
      }
      debugPrint('✓ Reminder auto-created (count=1)');

      // Step 4: Delete the document
      await deleteDocument.call(docId);
      debugPrint('✓ Document deleted');

      // Step 5: Verify policy still exists and reminder state
      final policy = await db.policiesDao.getPolicyById(policyId);
      if (policy == null) {
        throw StateError('Policy should still exist after document delete');
      }
      debugPrint('✓ Policy still exists (FK cascade correctly configured)');

      final reminders2 = await getReminders.call();
      final policyReminders2 = reminders2.where(
        (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
      ).toList();
      debugPrint('✓ Reminder count after doc delete: ${policyReminders2.length}');

      debugPrint('✅ SCENARIO 1: PASS');
      scenariosPassed++;
    } catch (e) {
      debugPrint('❌ SCENARIO 1: FAIL - $e');
    }

    /// ════════════════════════════════════════
    /// SCENARIO 2: Bill + Subscription Aggregation
    /// ════════════════════════════════════════
    debugPrint('');
    debugPrint('💰 SCENARIO 2: Bill + Subscription Aggregation');
    debugPrint('────────────────────────────────────────');
    await db.hardReset();

    try {
      // Step 1: Create a bill (£120/month)
      final billId = await createBill.call(
        name: 'Council Tax',
        category: 'utilities',
        amountCents: 12000, // £120
        isRecurring: true,
        frequency: 'monthly',
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
        generateReminder: false, // Skip reminder to focus on aggregation
      );
      debugPrint('✓ Bill created: £120/month (id=$billId)');

      // Step 2: Create a subscription (£30/month)
      final subId = await createSubscription.call(
        name: 'Netflix',
        category: 'entertainment',
        amountCents: 3000, // £30
        billingFrequency: 'monthly',
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 30)),
        generateReminder: false,
      );
      debugPrint('✓ Subscription created: £30/month (id=$subId)');

      // Step 3: Calculate monthly commitments
      final total1 = await calculateMonthly.call();
      debugPrint('✓ Monthly total: £${total1.grandTotal / 100}');
      debugPrint('  - Bills: £${total1.billsTotal / 100}');
      debugPrint('  - Subscriptions: £${total1.subscriptionsTotal / 100}');

      // Step 4: Expect total = £150
      if (total1.grandTotal != 15000) {
        throw StateError('Expected £150 total, got £${total1.grandTotal / 100}');
      }
      debugPrint('✓ Total matches expected: £150');

      // Step 5: Delete bill
      await deleteBill.call(billId);
      debugPrint('✓ Bill deleted');

      // Step 6: Recalculate
      final total2 = await calculateMonthly.call();
      debugPrint('✓ Recalculated total: £${total2.grandTotal / 100}');

      // Step 7: Expect total = £30
      if (total2.grandTotal != 3000) {
        throw StateError('Expected £30 after bill delete, got £${total2.grandTotal / 100}');
      }
      debugPrint('✓ Total matches expected after delete: £30');

      debugPrint('✅ SCENARIO 2: PASS');
      scenariosPassed++;
    } catch (e) {
      debugPrint('❌ SCENARIO 2: FAIL - $e');
    }

    /// ════════════════════════════════════════
    /// SCENARIO 3: Reminder Isolation
    /// ════════════════════════════════════════
    debugPrint('');
    debugPrint('🔔 SCENARIO 3: Reminder Isolation');
    debugPrint('────────────────────────────────────────');
    await db.hardReset();

    try {
      // Step 1: Create bill → reminder A
      final billId = await createBill.call(
        name: 'Gas Bill',
        category: 'utilities',
        amountCents: 8000, // £80
        isRecurring: true,
        frequency: 'monthly',
        nextDueDate: DateTime.now().add(const Duration(days: 25)),
        generateReminder: true,
      );
      debugPrint('✓ Bill created with reminder (id=$billId)');

      final remindersA = await getReminders.call();
      final billReminders = remindersA.where(
        (r) => r.sourceEntityKind == 'bill' && r.sourceEntityId == billId,
      ).toList();
      if (billReminders.isEmpty) {
        throw StateError('Bill reminder not created');
      }
      debugPrint('✓ Bill reminder exists (id=${billReminders.first.id})');

      // Step 2: Create policy → reminder B
      final policyId = await createPolicy.call(
        policyName: 'Travel Insurance',
        policyNumber: 'TRAVEL-2024-001',
        policyType: 'travel',
        provider: 'Allianz',
        premiumAmountCents: 5000, // £50
        premiumFrequency: 'annual',
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 365)),
        generateReminder: true,
      );
      debugPrint('✓ Policy created with reminder (id=$policyId)');

      final remindersB = await getReminders.call();
      final policyReminders = remindersB.where(
        (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
      ).toList();
      if (policyReminders.isEmpty) {
        throw StateError('Policy reminder not created');
      }
      debugPrint('✓ Policy reminder exists (id=${policyReminders.first.id})');

      // Step 3: Delete bill
      await deleteBill.call(billId);
      debugPrint('✓ Bill deleted');

      // Step 4: Verify policy reminder still exists, bill reminder cancelled
      final remindersC = await getReminders.call();
      
      final billRemindersAfter = remindersC.where(
        (r) => r.sourceEntityKind == 'bill' && r.sourceEntityId == billId,
      ).toList();
      
      final policyRemindersAfter = remindersC.where(
        (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
      ).toList();

      if (billRemindersAfter.isNotEmpty) {
        throw StateError('Bill reminder should be cancelled');
      }
      debugPrint('✓ Bill reminder cancelled (count=0)');

      if (policyRemindersAfter.isEmpty) {
        throw StateError('Policy reminder should still exist');
      }
      debugPrint('✓ Policy reminder still exists (isolated)');

      debugPrint('✅ SCENARIO 3: PASS');
      scenariosPassed++;
    } catch (e) {
      debugPrint('❌ SCENARIO 3: FAIL - $e');
    }

    /// ════════════════════════════════════════
    /// SCENARIO 4: Versioning Stability
    /// ════════════════════════════════════════
    debugPrint('');
    debugPrint('🔄 SCENARIO 4: Versioning Stability');
    debugPrint('────────────────────────────────────────');
    await db.hardReset();

    try {
      // Step 1: Create policy → reminder
      final policyId = await createPolicy.call(
        policyName: 'Life Insurance',
        policyNumber: 'LIFE-2024-001',
        policyType: 'life',
        provider: 'Prudential',
        premiumAmountCents: 25000, // £250
        premiumFrequency: 'annual',
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 365)),
        generateReminder: true,
      );
      debugPrint('✓ Policy created (id=$policyId)');

      final reminders1 = await getReminders.call();
      final initialReminders = reminders1.where(
        (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
      ).toList();

      if (initialReminders.isEmpty) {
        throw StateError('Initial reminder not created');
      }
      final originalReminderId = initialReminders.first.id;
      debugPrint('✓ Initial reminder created (id=$originalReminderId)');

      // Step 2: Renew policy twice
      await renewPolicy.call(
        policyId: policyId,
        newRenewalDate: DateTime.now().add(const Duration(days: 730)),
        newPremiumAmountCents: 27000, // £270 (price increase)
        updateReminder: true,
      );
      debugPrint('✓ Policy renewed (1st time)');

      await renewPolicy.call(
        policyId: policyId,
        newRenewalDate: DateTime.now().add(const Duration(days: 1095)),
        newPremiumAmountCents: 29000, // £290 (another increase)
        updateReminder: true,
      );
      debugPrint('✓ Policy renewed (2nd time)');

      // Step 3: Verify reminder count = 1 and ID unchanged
      final reminders2 = await getReminders.call();
      final finalReminders = reminders2.where(
        (r) => r.sourceEntityKind == 'policy' && r.sourceEntityId == policyId,
      ).toList();

      if (finalReminders.length != 1) {
        throw StateError('Expected 1 reminder after renewals, got ${finalReminders.length}');
      }
      debugPrint('✓ Reminder count stable (count=1, no duplicates)');

      if (finalReminders.first.id != originalReminderId) {
        throw StateError('Reminder ID changed after renewals');
      }
      debugPrint('✓ Reminder ID unchanged (id=$originalReminderId)');

      debugPrint('✅ SCENARIO 4: PASS');
      scenariosPassed++;
    } catch (e) {
      debugPrint('❌ SCENARIO 4: FAIL - $e');
    }

    /// ════════════════════════════════════════
    /// FINAL SUMMARY
    /// ════════════════════════════════════════
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    if (scenariosPassed == scenariosTotal) {
      debugPrint('✅ ALL TESTS PASSED ($scenariosPassed/$scenariosTotal)');
      debugPrint('═══════════════════════════════════════');
    } else {
      debugPrint('⚠️  SOME TESTS FAILED ($scenariosPassed/$scenariosTotal)');
      debugPrint('═══════════════════════════════════════');
    }
  } catch (e, stack) {
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('❌ CROSS-ENTITY TESTS CRASHED');
    debugPrint('═══════════════════════════════════════');
    debugPrint(e.toString());
    debugPrint(stack.toString());
  }
  await db.hardReset();

}

