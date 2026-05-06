import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/money.dart';
import '../../validation/date_rules.dart';
import '../../validation/versioning_rules.dart';

class UpdateBillUseCase {
  final AppDatabase _database;
  UpdateBillUseCase(this._database);

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
    if (billId <= 0) throw ArgumentError('Invalid bill ID');

    final existing = await _database.billsDao.getBillById(billId);
    if (existing == null) throw StateError('Bill $billId not found');

    Money.validateNullablePositiveAmount(amountCents);
    if (nextDueDate != null) {
      DateRules.validateFutureDate(nextDueDate);
      DateRules.validateReasonableFutureDate(nextDueDate);
    }
    VersioningRules.validateVersionNumber(existing.version);
    VersioningRules.validatePreviousVersionReference(existing.version + 1, billId);

    final newVersion = BillsCompanion.insert(
      name: name ?? existing.name,
      category: category ?? existing.category,
      amountCents: amountCents ?? existing.amountCents,
      version: Value(existing.version + 1),
      previousVersionId: Value(billId),
      description: Value(description ?? existing.description),
      provider: Value(provider ?? existing.provider),
      currency: Value(existing.currency),
      isRecurring: Value(isRecurring ?? existing.isRecurring),
      frequency: Value(frequency ?? existing.frequency),
      nextDueDate: Value(nextDueDate ?? existing.nextDueDate),
      lastPaidDate: Value(existing.lastPaidDate),
      status: Value(status ?? existing.status),
      isAutoPay: Value(isAutoPay ?? existing.isAutoPay),
      accountNumber: Value(existing.accountNumber),
      referenceNumber: Value(existing.referenceNumber),
      metadata: Value(existing.metadata),
      documentId: Value(existing.documentId),
    );

    return await _database.transaction(() async {
      final newVersionId = await _database.billsDao.createBill(newVersion);

      if (updateReminder && nextDueDate != null) {
        await _updateBillReminder(billId: billId, dueDate: nextDueDate);
      }

      return newVersionId;
    });
  }

  Future<void> _updateBillReminder({
    required int billId,
    required DateTime dueDate,
  }) async {
    const leadIn = 3;
    final firesAt = dueDate.subtract(const Duration(days: leadIn));
    if (firesAt.isBefore(DateTime.now())) return;

    final existing =
        await _database.remindersDao.getForSource('bill', billId);
    final current = existing
        .where((r) =>
            r.triggerTypeId == 'payment_due_date' && r.state == 'pending')
        .firstOrNull;

    if (current != null) {
      await _database.remindersDao
          .updateTargetDate(current.id, dueDate, newFiresAt: firesAt);
    } else {
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
}
