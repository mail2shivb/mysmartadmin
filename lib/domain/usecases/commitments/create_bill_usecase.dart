import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/entity_validators.dart';

/// Use case for creating a new bill
///
/// Creates bill and optionally generates a reminder for next due date
class CreateBillUseCase {
  final AppDatabase _database;

  CreateBillUseCase(this._database);

  /// Create a new bill with optional reminder generation
  /// 
  /// Returns the ID of the newly created bill
  Future<int> call({
    required String name,
    required String category,
    required int amountCents,
    required bool isRecurring,
    String? description,
    String? provider,
    String? frequency,
    DateTime? nextDueDate,
    bool isAutoPay = false,
    String currency = 'GBP',
    bool generateReminder = true,
  }) async {
    // Use centralized entity validator
    EntityValidators.validateBill(
      name: name,
      category: category,
      amountCents: amountCents,
      isRecurring: isRecurring,
      frequency: frequency,
      nextDueDate: nextDueDate,
    );

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Create the bill
      final billId = await _database.billsDao.createBill(
        BillsCompanion.insert(
          name: name,
          category: category,
          amountCents: amountCents,
          isRecurring: Value(isRecurring),
          description: Value(description),
          provider: Value(provider),
          frequency: Value(frequency),
          nextDueDate: Value(nextDueDate),
          isAutoPay: Value(isAutoPay),
          currency: Value(currency),
          status: const Value('active'),
        ),
      );

      // Auto-generate reminder if requested and nextDueDate is set
      if (generateReminder && nextDueDate != null) {
        await _generateBillReminder(
          billId: billId,
          billName: name,
          dueDate: nextDueDate,
        );
      }

      return billId;
    });
  }

  /// Generate reminder for bill due date
  Future<void> _generateBillReminder({
    required int billId,
    required String billName,
    required DateTime dueDate,
  }) async {
    // Calculate reminder date (3 days before due date)
    final reminderDate = dueDate.subtract(const Duration(days: 3));
    
    // Only create reminder if it's in the future
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    // Check if reminder already exists for this bill using entity-based detection
    final existingReminders = await _database.remindersDao.getAllReminders();
    final duplicateExists = existingReminders.any(
      (r) => r.description != null &&
             r.description!.contains('[ENTITY:bill:$billId]') &&
             r.reminderType == 'bill_due' && 
             r.status != 'completed',
    );

    if (duplicateExists) {
      return;
    }

    // Create the reminder with entity identifier in description
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

