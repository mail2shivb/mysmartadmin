// ignore_for_file: avoid_print, unused_local_variable

/// Example usage of the B8 database implementation.
///
/// This file demonstrates how to use the DAOs and database.
/// DO NOT import this in production code — it is for reference only.
library;

import 'package:drift/drift.dart';
import 'package:mysmartadmin/data/local/app_database.dart';

Future<void> exampleUsage() async {
  final database = AppDatabase();

  // ── EXAMPLE 1: Create a document (classification_pending) ─────────────────

  final documentId = await database.documentsDao.insertDocument(
    DocumentsCompanion.insert(
      title: 'Home Insurance Policy 2024',
      description: const Value('Annual home insurance policy'),
      issuer: const Value('Aviva'),
      expiryDate: Value(DateTime(2024, 12, 31)),
      source: const Value('manual'),
    ),
  );
  print('Created document: $documentId');

  // ── EXAMPLE 2: Classify a document ───────────────────────────────────────

  await database.documentsDao.classify(
    id: documentId,
    documentTypeId: 'home_insurance_policy',
    categoryId: 'home_insurance',
    domainId: 'insurance_protection',
    taxonomyVersion: 1,
  );

  // ── EXAMPLE 3: Create a reminder for a document ──────────────────────────

  final targetDate = DateTime(2024, 12, 31);
  const leadInDays = 30;
  final firesAt = targetDate.subtract(const Duration(days: leadInDays));

  await database.remindersDao.createReminder(
    RemindersCompanion.insert(
      sourceEntityKind: 'document',
      sourceEntityId: documentId,
      triggerTypeId: 'expiry_date',
      targetDate: targetDate,
      leadInDaysSnapshot: const Value(leadInDays),
      firesAt: firesAt,
    ),
  );

  // ── EXAMPLE 4: Create a bill ──────────────────────────────────────────────

  final billId = await database.billsDao.createBill(
    BillsCompanion.insert(
      name: 'Council Tax',
      category: 'council_tax',
      provider: const Value('Local Council'),
      amountCents: 15000,
      currency: const Value('GBP'),
      isRecurring: const Value(true),
      frequency: const Value('monthly'),
      nextDueDate: Value(DateTime.now().add(const Duration(days: 30))),
      status: const Value('active'),
      isAutoPay: const Value(true),
    ),
  );

  // ── EXAMPLE 5: Create a subscription ─────────────────────────────────────

  await database.subscriptionsDao.createSubscription(
    SubscriptionsCompanion.insert(
      name: 'Netflix',
      category: 'streaming',
      provider: const Value('Netflix Inc'),
      amountCents: 1099,
      currency: const Value('GBP'),
      billingFrequency: 'monthly',
      startDate: DateTime(2023, 1, 1),
      renewalDate: DateTime.now().add(const Duration(days: 15)),
      status: const Value('active'),
      autoRenew: const Value(true),
    ),
  );

  // ── EXAMPLE 6: Create a policy ────────────────────────────────────────────

  final policyId = await database.policiesDao.createPolicy(
    PoliciesCompanion.insert(
      policyNumber: 'HI-2024-123456',
      policyName: 'Home Insurance Comprehensive',
      policyType: 'home',
      provider: 'Aviva',
      coverageType: const Value('buildings_and_contents'),
      coverageAmountCents: const Value(30000000),
      currency: const Value('GBP'),
      premiumAmountCents: 45000,
      premiumFrequency: 'annual',
      startDate: DateTime(2024, 1, 1),
      renewalDate: DateTime(2024, 12, 31),
      status: const Value('active'),
      autoRenew: const Value(true),
      excessAmountCents: const Value(25000),
      providerPhone: const Value('0800-123-4567'),
    ),
  );

  // ── EXAMPLE 7: Link a document to a property via Relationships ────────────

  await database.relationshipsDao.insertRelationship(
    RelationshipsCompanion.insert(
      sourceEntityKind: 'property',
      sourceEntityId: 1,
      targetEntityKind: 'document',
      targetEntityId: documentId,
      relationshipTypeId: 'property_policy',
    ),
  );

  // ── EXAMPLE 8: OCR field confirmation meta ────────────────────────────────

  await database.documentFieldsMetaDao.upsertConfirmations(
    documentId,
    '{"expiry_date":{"source":"ocr","confirmed":false},'
    '"issuer":{"source":"manual","confirmed":true}}',
  );

  // ── EXAMPLE 9: Query expiring documents ──────────────────────────────────

  final now = DateTime.now();
  final in30Days = now.add(const Duration(days: 30));
  final expiringDocs =
      await database.documentsDao.getExpiringBetween(now, in30Days);

  print('Documents expiring in 30 days: ${expiringDocs.length}');
  for (final doc in expiringDocs) {
    print('- ${doc.title} expires ${doc.expiryDate}');
  }

  // ── EXAMPLE 10: Full-text search ─────────────────────────────────────────

  final ftsResults = await database.ftsSearch('insurance');
  print('FTS results for "insurance": ${ftsResults.length}');

  // ── EXAMPLE 11: Calculate monthly costs ──────────────────────────────────

  final billsCost = await database.billsDao.calculateMonthlyTotal();
  final subsCost = await database.subscriptionsDao.calculateMonthlyTotal();
  final policyCost = await database.policiesDao.calculateMonthlyTotal();
  print('Monthly: bills=${billsCost / 100} subs=${subsCost / 100} '
      'policies=${policyCost / 100}');

  // ── EXAMPLE 12: Dismiss reminders when source is deleted ─────────────────

  await database.remindersDao.dismissForSource('document', documentId);
  await database.documentsDao.softDeleteDocument(documentId);

  // ── EXAMPLE 13: Watch pending reminders ──────────────────────────────────

  final sub = database.remindersDao.watchPending().listen((list) {
    print('Pending reminders: ${list.length}');
  });
  await Future.delayed(const Duration(seconds: 1));
  await sub.cancel();

  // ── EXAMPLE 14: Statistics ────────────────────────────────────────────────

  final totalDocuments = await database.documentsDao.countAll();
  final pendingClassification =
      await database.documentsDao.countPendingClassification();
  final activeBills = await database.billsDao.countActiveBills();
  final activeSubs =
      await database.subscriptionsDao.countActiveSubscriptions();
  final activePolicies = await database.policiesDao.countActivePolicies();

  print('Documents: $totalDocuments (pending classification: $pendingClassification)');
  print('Bills: $activeBills  Subs: $activeSubs  Policies: $activePolicies');

  await database.close();
}
