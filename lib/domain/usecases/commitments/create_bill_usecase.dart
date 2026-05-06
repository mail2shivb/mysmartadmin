import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/entity_validators.dart';

class CreateBillUseCase {
  final AppDatabase _database;
  CreateBillUseCase(this._database);

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
    EntityValidators.validateBill(
      name: name,
      category: category,
      amountCents: amountCents,
      isRecurring: isRecurring,
      frequency: frequency,
      nextDueDate: nextDueDate,
    );

    return await _database.transaction(() async {
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

      if (generateReminder && nextDueDate != null) {
        await _generateBillReminder(billId: billId, dueDate: nextDueDate);
      }

      return billId;
    });
  }

  Future<void> _generateBillReminder({
    required int billId,
    required DateTime dueDate,
  }) async {
    const leadIn = 3;
    final firesAt = dueDate.subtract(const Duration(days: leadIn));
    if (firesAt.isBefore(DateTime.now())) return;

    final existing = await _database.remindersDao.getForSource('bill', billId);
    final dup = existing.any((r) =>
        r.triggerTypeId == 'payment_due_date' && r.state != 'completed');
    if (dup) return;

    await _database.remindersDao.createReminder(
      RemindersCompanion.insert(
        sourceEntityKind: 'bill',
        sourceEntityId: billId,
        triggerTypeId: 'payment_due_date',
        targetDate: dueDate,
        leadInDaysSnapshot: const Value(leadIn),
        firesAt: firesAt,
      ),
    );
  }
}
