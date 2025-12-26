import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/tables/bills.dart';
import '../../../data/local/tables/reminders.dart';
import '../../validation/money.dart';
import '../../validation/date_rules.dart';
import '../../validation/versioning_rules.dart';

/// Use case for updating an existing bill
///
/// Creates new version and optionally updates reminders
class UpdateBillUseCase {
  final AppDatabase _database;

  UpdateBillUseCase(this._database);

  /// Update bill and create new version
  /// 
  /// Returns the ID of the new bill version
  Future<int> call({
    required int billId,
    String? name,
    String? description,
    String? category,
    String? provider,
    int? amountCents,
    bool? isRecurring,
    String? frequency,
    DateTime? nextDueDate,
    bool? isAutoPay,
    String? status,
    bool updateReminder = true,
  }) async {
    if (billId <= 0) {
      throw ArgumentError('Invalid bill ID');
    }

    // Verify bill exists
    final existingBill = await _database.billsDao.getBillById(billId);
    if (existingBill == null) {
      throw StateError('Bill with ID $billId not found');
    }

    // Validate amount using centralized money validator
    Money.validateNullablePositiveAmount(amountCents);

    // Validate next due date using centralized date validator
    if (nextDueDate != null) {
      DateRules.validateFutureDate(nextDueDate);
      DateRules.validateReasonableFutureDate(nextDueDate);
    }

    // Validate versioning rules
    VersioningRules.validateVersionNumber(existingBill.version);
    VersioningRules.validatePreviousVersionReference(
      existingBill.version + 1,
      billId,
    );

    // Build complete companion for new version
    // Copy all required fields from existing bill, override with new values
    final newVersionCompanion = BillsCompanion.insert(
      // Required fields - copy from existing, override if provided
      name: name ?? existingBill.name,
      category: category ?? existingBill.category,
      amountCents: amountCents ?? existingBill.amountCents,
      
      // Versioning fields
      version: Value(existingBill.version + 1),
      previousVersionId: Value(billId),
      
      // Optional fields - preserve existing or override
      description: Value(description ?? existingBill.description),
      provider: Value(provider ?? existingBill.provider),
      currency: Value(existingBill.currency),
      isRecurring: Value(isRecurring ?? existingBill.isRecurring),
      frequency: Value(frequency ?? existingBill.frequency),
      nextDueDate: Value(nextDueDate ?? existingBill.nextDueDate),
      lastPaidDate: Value(existingBill.lastPaidDate),
      status: Value(status ?? existingBill.status),
      isAutoPay: Value(isAutoPay ?? existingBill.isAutoPay),
      accountNumber: Value(existingBill.accountNumber),
      referenceNumber: Value(existingBill.referenceNumber),
      metadata: Value(existingBill.metadata),
      documentId: Value(existingBill.documentId),
    );

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Insert new version directly (bypass createBillVersion to avoid double-fetch)
      final newVersionId = await _database.billsDao.createBill(newVersionCompanion);

      // Update reminder if next due date changed and updateReminder is true
      if (updateReminder && nextDueDate != null) {
        await _updateBillReminder(
          billId: billId,
          billName: name ?? existingBill.name,
          dueDate: nextDueDate,
        );
      }

      return newVersionId;
    });
  }

  /// Update or create reminder for bill
  Future<void> _updateBillReminder({
    required int billId,
    required String billName,
    required DateTime dueDate,
  }) async {
    // Calculate reminder date (3 days before due date)
    final reminderDate = dueDate.subtract(const Duration(days: 3));
    
    // Only create/update reminder if it's in the future
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    // Find existing pending reminder for this bill using entity-based detection
    final allReminders = await _database.remindersDao.getPendingReminders();
    final existingReminder = allReminders.where(
      (r) => r.description != null &&
             r.description!.contains('[ENTITY:bill:$billId]') &&
             r.reminderType == 'bill_due',
    ).firstOrNull;

    if (existingReminder != null) {
      // Update existing reminder date
      await _database.remindersDao.updateReminderDate(
        existingReminder.id,
        reminderDate,
      );
    } else {
      // Create new reminder with entity identifier
      await _database.remindersDao.createReminder(
        RemindersCompanion.insert(
          title: 'Bill Due: $billName',
          description: Value('[ENTITY:bill:$billId] Bill payment due on ${dueDate.toIso8601String().split('T')[0]}'),
          reminderDate: reminderDate,
          reminderType: 'bill_due',
          status: const Value('pending'),
        ),
      );
    }
  }
}

