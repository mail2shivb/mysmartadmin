// ignore_for_file: avoid_print, unused_local_variable

/// Example usage of the B8 database implementation.
///
/// This file demonstrates how to use the DAOs and database.
/// DO NOT import this in production code - it's for reference only.
library database_usage_examples;

import 'package:drift/drift.dart';
import 'package:mysmartadmin/data/local/app_database.dart';

Future<void> exampleUsage() async {
  // Initialize database
  final database = AppDatabase();

  // ============================================================
  // EXAMPLE 1: Create a document
  // ============================================================

  final documentId = await database.documentsDao.insertDocument(
    DocumentsCompanion.insert(
      title: 'Home Insurance Policy 2024',
      category: 'insurance',
      documentType: 'policy',
      description: Value('Annual home insurance policy'),
      expiryDate: Value(DateTime(2024, 12, 31)),
      tags: Value('insurance,home,buildings,contents'),
    ),
  );

  print('Created document with ID: $documentId');

  // ============================================================
  // EXAMPLE 2: Create a bill
  // ============================================================

  final billId = await database.billsDao.createBill(
    BillsCompanion.insert(
      name: 'Council Tax',
      category: 'council_tax',
      provider: Value('Local Council'),
      amountCents: 15000, // £150.00 per month
      currency: Value('GBP'),
      isRecurring: Value(true),
      frequency: Value('monthly'),
      nextDueDate: Value(DateTime.now().add(Duration(days: 30))),
      status: Value('active'),
      isAutoPay: Value(true),
    ),
  );

  // ============================================================
  // EXAMPLE 3: Create a reminder for the bill
  // ============================================================

  await database.remindersDao.createReminder(
    RemindersCompanion.insert(
      title: 'Council Tax Due',
      reminderType: 'bill_due',
      reminderDate: DateTime.now().add(const Duration(days: 5)),
      entityType: 'bill',
      entityId: billId,
      description: Value('[ENTITY:bill:$billId] Payment due soon'),
    ),
  );

  // ============================================================
  // EXAMPLE 4: Create a subscription
  // ============================================================

  await database.subscriptionsDao.createSubscription(
    SubscriptionsCompanion.insert(
      name: 'Netflix',
      category: 'streaming',
      provider: Value('Netflix Inc'),
      amountCents: 1099, // £10.99 per month
      currency: Value('GBP'),
      billingFrequency: 'monthly',
      startDate: DateTime(2023, 1, 1),
      renewalDate: DateTime.now().add(Duration(days: 15)),
      status: Value('active'),
      autoRenew: Value(true),
    ),
  );

  // ============================================================
  // EXAMPLE 5: Create an insurance policy
  // ============================================================

  final policyId = await database.policiesDao.createPolicy(
    PoliciesCompanion.insert(
      policyNumber: 'HI-2024-123456',
      policyName: 'Home Insurance Comprehensive',
      policyType: 'home',
      provider: 'Aviva',
      coverageType: Value('buildings_and_contents'),
      coverageAmountCents: Value(30000000), // £300,000 coverage
      currency: Value('GBP'),
      premiumAmountCents: 45000, // £450 per year
      premiumFrequency: 'annual',
      startDate: DateTime(2024, 1, 1),
      renewalDate: DateTime(2024, 12, 31),
      status: Value('active'),
      autoRenew: Value(true),
      excessAmountCents: Value(25000), // £250 excess
      providerPhone: Value('0800-123-4567'),
    ),
  );

  // ============================================================
  // EXAMPLE 6: Link documents
  // ============================================================

  // Create a claim document
  final claimDocId = await database.documentsDao.insertDocument(
    DocumentsCompanion.insert(
      title: 'Home Insurance Claim - Water Damage',
      category: 'insurance',
      documentType: 'claim',
      documentDate: Value(DateTime.now()),
    ),
  );

  // Link the claim to the policy document
  await database.documentLinksDao.createLink(
    DocumentLinksCompanion.insert(
      sourceDocumentId: documentId,
      targetDocumentId: claimDocId,
      linkType: 'claim',
      notes: Value('Water damage claim filed 2024-12-26'),
    ),
  );

  // ============================================================
  // EXAMPLE 7: Query expiring documents
  // ============================================================

  final now = DateTime.now();
  final in30Days = now.add(Duration(days: 30));

  final expiringDocs = await database.documentsDao
      .getDocumentsExpiringBetween(now, in30Days);

  print('Documents expiring in next 30 days: ${expiringDocs.length}');
  for (final doc in expiringDocs) {
    print('- ${doc.title} expires on ${doc.expiryDate}');
  }

  // ============================================================
  // EXAMPLE 8: Calculate monthly costs
  // ============================================================

  final billsCost = await database.billsDao.calculateMonthlyTotal();
  final subsCost = await database.subscriptionsDao.calculateMonthlyTotal();
  final policyCost = await database.policiesDao.calculateMonthlyTotal();

  final totalMonthlyCents = billsCost + subsCost + policyCost;
  final totalMonthlyPounds = totalMonthlyCents / 100;

  print('Monthly costs:');
  print('  Bills: £${billsCost / 100}');
  print('  Subscriptions: £${subsCost / 100}');
  print('  Insurance: £${policyCost / 100}');
  print('  TOTAL: £$totalMonthlyPounds');

  // ============================================================
  // EXAMPLE 9: Get pending reminders
  // ============================================================

  final pendingReminders = await database.remindersDao.getPendingReminders();
  print('Pending reminders: ${pendingReminders.length}');

  // ============================================================
  // EXAMPLE 10: Mark bill as paid
  // ============================================================

  await database.billsDao.markBillAsPaid(billId, DateTime.now());
  await database.billsDao.updateNextDueDate(
    billId,
    DateTime.now().add(Duration(days: 30)),
  );

  // ============================================================
  // EXAMPLE 11: Soft delete and restore
  // ============================================================

  // Soft delete a document
  await database.documentsDao.softDeleteDocument(claimDocId);

  // Restore it
  await database.documentsDao.restoreDocument(claimDocId);

  // ============================================================
  // EXAMPLE 12: Watch for real-time updates (for UI)
  // ============================================================

  // This would typically be used in a StreamBuilder widget
  final remindersStream = database.remindersDao.watchPendingReminders();

  // Subscribe to changes
  final subscription = remindersStream.listen((reminders) {
    print('Reminders updated: ${reminders.length} pending');
  });

  // Don't forget to cancel when done
  await Future.delayed(Duration(seconds: 1));
  await subscription.cancel();

  // ============================================================
  // EXAMPLE 13: Search documents
  // ============================================================

  final searchResults = await database.documentsDao
      .searchDocuments('insurance');

  print('Search results for "insurance": ${searchResults.length}');

  // ============================================================
  // EXAMPLE 14: Get document versions
  // ============================================================

  // Create a new version of a bill (e.g., price increase)
  final newVersionId = await database.billsDao.createBillVersion(
    billId,
    BillsCompanion(
      amountCents: Value(16000), // Price increased to £160
      updatedAt: Value(DateTime.now()),
    ),
  );

  // Get all versions
  final versions = await database.billsDao.getBillVersions(billId);
  print('Bill has ${versions.length} versions');

  // ============================================================
  // EXAMPLE 15: Get unused subscriptions
  // ============================================================

  final unusedSubs = await database.subscriptionsDao
      .getUnusedSubscriptions(90); // Not used in 90 days

  print('Potentially unused subscriptions: ${unusedSubs.length}');
  for (final sub in unusedSubs) {
    print('- ${sub.name} (last used: ${sub.lastUsedDate})');
  }

  // ============================================================
  // EXAMPLE 16: Count statistics
  // ============================================================

  final totalDocuments = await database.documentsDao.countAllDocuments();
  final activeBills = await database.billsDao.countActiveBills();
  final activeSubs = await database.subscriptionsDao.countActiveSubscriptions();
  final activePolicies = await database.policiesDao.countActivePolicies();

  print('Statistics:');
  print('  Documents: $totalDocuments');
  print('  Active Bills: $activeBills');
  print('  Active Subscriptions: $activeSubs');
  print('  Active Policies: $activePolicies');

  // ============================================================
  // Clean up
  // ============================================================

  await database.close();
  print('Database closed');
}

/// Example of using reactive streams in a Flutter widget
///
/// ```dart
/// class RemindersWidget extends StatelessWidget {
///   final AppDatabase database;
///
///   const RemindersWidget({required this.database});
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilder<List<ReminderEntity>>(
///       stream: database.remindersDao.watchPendingReminders(),
///       builder: (context, snapshot) {
///         if (snapshot.connectionState == ConnectionState.waiting) {
///           return CircularProgressIndicator();
///         }
///
///         if (snapshot.hasError) {
///           return Text('Error: ${snapshot.error}');
///         }
///
///         final reminders = snapshot.data ?? [];
///
///         if (reminders.isEmpty) {
///           return Text('No pending reminders');
///         }
///
///         return ListView.builder(
///           itemCount: reminders.length,
///           itemBuilder: (context, index) {
///             final reminder = reminders[index];
///             return ListTile(
///               title: Text(reminder.title),
///               subtitle: Text(reminder.reminderDate.toString()),
///               trailing: IconButton(
///                 icon: Icon(Icons.check),
///                 onPressed: () async {
///                   await database.remindersDao.completeReminder(reminder.id);
///                 },
///               ),
///             );
///           },
///         );
///       },
///     );
///   }
/// }
/// ```

