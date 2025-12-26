import 'package:flutter/foundation.dart';

import '../data/local/app_database.dart';
import '../domain/usecases/commitments/create_bill_usecase.dart';
import '../domain/usecases/commitments/update_bill_usecase.dart';
import '../domain/usecases/commitments/delete_bill_usecase.dart';
import '../domain/usecases/commitments/calculate_monthly_commitments_usecase.dart';
import '../domain/usecases/reminders/get_active_reminders_usecase.dart';

Future<void> runDomainSmokeTest() async {
  debugPrint('==============================');
  debugPrint('🚀 DOMAIN SMOKE TEST STARTED');
  debugPrint('==============================');

  final database = AppDatabase();

  try {
    /// -------------------------------
    /// FLOW 1 — CREATE BILL
    /// -------------------------------
    debugPrint('➡️ Creating bill...');

    final createBill = CreateBillUseCase(database);

    debugPrint('[DEBUG] BEFORE createBill.call()');
    final billId = await createBill.call(
      name: 'Electricity',
      category: 'utilities',
      amountCents: 12000, // £120.00
      isRecurring: true,
      frequency: 'monthly',
      nextDueDate: DateTime.now().add(const Duration(days: 14)),
      generateReminder: true,
    );
    debugPrint('[DEBUG] AFTER createBill.call() - billId=$billId');

    debugPrint('✅ Bill created with ID: $billId');

    /// -------------------------------
    /// FLOW 2 — VERIFY REMINDER
    /// -------------------------------
    final getReminders = GetActiveRemindersUseCase(database);
    
    debugPrint('[DEBUG] BEFORE getReminders.call() #1');
    final reminders = await getReminders.call();
    debugPrint('[DEBUG] AFTER getReminders.call() #1 - count=${reminders.length}');

    debugPrint('📌 Active reminders count: ${reminders.length}');
    for (final r in reminders) {
      debugPrint('🔔 Reminder → id=${r.id}, type=${r.reminderType}, status=${r.status}');
    }

    /// -------------------------------
    /// FLOW 3 — MONTHLY AGGREGATION
    /// -------------------------------
    final calculateMonthly = CalculateMonthlyCommitmentsUseCase(database);
    
    debugPrint('[DEBUG] BEFORE calculateMonthly.call()');
    final monthlyResult = await calculateMonthly.call();
    debugPrint('[DEBUG] AFTER calculateMonthly.call()');

    debugPrint('💰 Monthly total: £${monthlyResult.grandTotal / 100}');
    debugPrint('   Bills: £${monthlyResult.billsTotal / 100}');
    debugPrint('   Subscriptions: £${monthlyResult.subscriptionsTotal / 100}');

    /// -------------------------------
    /// FLOW 4 — UPDATE BILL (VERSIONING)
    /// -------------------------------
    debugPrint('➡️ Updating bill (price change)...');

    final updateBill = UpdateBillUseCase(database);

    debugPrint('[DEBUG] BEFORE updateBill.call()');
    final newVersionId = await updateBill.call(
      billId: billId,
      amountCents: 13500, // £135.00
      updateReminder: true,
    );
    debugPrint('[DEBUG] AFTER updateBill.call() - newVersionId=$newVersionId');

    debugPrint('✅ Bill updated with new version ID: $newVersionId');

    debugPrint('[DEBUG] BEFORE getReminders.call() #2');
    final remindersAfterUpdate = await getReminders.call();
    debugPrint('[DEBUG] AFTER getReminders.call() #2 - count=${remindersAfterUpdate.length}');
    
    debugPrint('🔁 Reminders after update: ${remindersAfterUpdate.length}');

    /// -------------------------------
    /// FLOW 5 — DELETE BILL
    /// -------------------------------
    debugPrint('➡️ Deleting bill...');

    final deleteBill = DeleteBillUseCase(database);
    
    debugPrint('[DEBUG] BEFORE deleteBill.call()');
    await deleteBill.call(billId);
    debugPrint('[DEBUG] AFTER deleteBill.call()');

    debugPrint('🗑️ Bill soft-deleted');

    debugPrint('[DEBUG] BEFORE getReminders.call() #3');
    final remindersAfterDelete = await getReminders.call();
    debugPrint('[DEBUG] AFTER getReminders.call() #3 - count=${remindersAfterDelete.length}');
    
    debugPrint('❌ Active reminders after delete: ${remindersAfterDelete.length}');

    debugPrint('==============================');
    debugPrint('✅ DOMAIN SMOKE TEST PASSED');
    debugPrint('==============================');
  } catch (e, stack) {
    debugPrint('❌ DOMAIN SMOKE TEST FAILED');
    debugPrint(e.toString());
    debugPrint(stack.toString());
  } finally {
    debugPrint('[DEBUG] BEFORE database.close()');
    await database.close();
    debugPrint('[DEBUG] AFTER database.close()');
  }
}
