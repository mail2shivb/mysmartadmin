import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/bills.dart';

part 'bills_dao.g.dart';

/// Data Access Object for Bills
/// 
/// Manages recurring and one-off bills
@DriftAccessor(tables: [Bills])
class BillsDao extends DatabaseAccessor<AppDatabase> with _$BillsDaoMixin {
  BillsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new bill
  Future<int> createBill(BillsCompanion bill) {
    return into(bills).insert(bill);
  }

  /// Create multiple bills
  Future<void> createBills(List<BillsCompanion> billList) async {
    await batch((batch) {
      batch.insertAll(bills, billList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a bill by ID
  Future<BillEntity?> getBillById(int id) {
    return (select(bills)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all bills
  Future<List<BillEntity>> getAllBills() {
    return (select(bills)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
  }

  /// Get bills by category
  Future<List<BillEntity>> getBillsByCategory(String category) {
    return (select(bills)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
  }

  /// Get bills by status
  Future<List<BillEntity>> getBillsByStatus(String status) {
    return (select(bills)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
  }

  /// Get active bills
  Future<List<BillEntity>> getActiveBills() {
    return getBillsByStatus('active');
  }

  /// Get recurring bills
  Future<List<BillEntity>> getRecurringBills() {
    return (select(bills)
          ..where((t) => t.isRecurring.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
  }

  /// Get bills due within a date range
  Future<List<BillEntity>> getBillsDueBetween(DateTime start, DateTime end) {
    return (select(bills)
          ..where((t) => t.nextDueDate.isBetweenValues(start, end))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
  }

  /// Get bills due this month
  Future<List<BillEntity>> getBillsDueThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getBillsDueBetween(startOfMonth, endOfMonth);
  }

  /// Get bills by provider
  Future<List<BillEntity>> getBillsByProvider(String provider) {
    return (select(bills)
          ..where((t) => t.provider.equals(provider))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull()))
        .get();
  }

  /// Get bills on auto-pay
  Future<List<BillEntity>> getAutoPayBills() {
    return (select(bills)
          ..where((t) => t.isAutoPay.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull()))
        .get();
  }

  /// Stream all bills
  Stream<List<BillEntity>> watchAllBills() {
    return (select(bills)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .watch();
  }

  /// Stream bills by category
  Stream<List<BillEntity>> watchBillsByCategory(String category) {
    return (select(bills)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a bill
  Future<bool> updateBill(BillEntity bill) {
    return update(bills).replace(bill);
  }

  /// Mark bill as paid
  Future<int> markBillAsPaid(int id, DateTime paidDate) {
    return (update(bills)..where((t) => t.id.equals(id))).write(
      BillsCompanion(
        lastPaidDate: Value(paidDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update next due date
  Future<int> updateNextDueDate(int id, DateTime nextDueDate) {
    return (update(bills)..where((t) => t.id.equals(id))).write(
      BillsCompanion(
        nextDueDate: Value(nextDueDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update bill status
  Future<int> updateBillStatus(int id, String status) {
    return (update(bills)..where((t) => t.id.equals(id))).write(
      BillsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Pause a bill
  Future<int> pauseBill(int id) {
    return updateBillStatus(id, 'paused');
  }

  /// Cancel a bill
  Future<int> cancelBill(int id) {
    return updateBillStatus(id, 'cancelled');
  }

  /// Activate a bill
  Future<int> activateBill(int id) {
    return updateBillStatus(id, 'active');
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a bill
  Future<int> softDeleteBill(int id) {
    return (update(bills)..where((t) => t.id.equals(id))).write(
      BillsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a bill
  Future<int> hardDeleteBill(int id) {
    return (delete(bills)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted bill
  Future<int> restoreBill(int id) {
    return (update(bills)..where((t) => t.id.equals(id))).write(
      const BillsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total monthly bills (in cents)
  Future<int> calculateMonthlyTotal() async {
    final recurringBills = await getRecurringBills();
    int total = 0;

    for (final bill in recurringBills) {
      if (bill.status == 'active') {
        // Convert to monthly equivalent
        switch (bill.frequency) {
          case 'monthly':
            total += bill.amountCents;
            break;
          case 'quarterly':
            total += (bill.amountCents / 3).round();
            break;
          case 'annual':
            total += (bill.amountCents / 12).round();
            break;
        }
      }
    }

    return total;
  }

  /// Count bills by category
  Future<int> countBillsByCategory(String category) async {
    final query = selectOnly(bills)
      ..addColumns([bills.id.count()])
      ..where(bills.category.equals(category))
      ..where(bills.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(bills.id.count()) ?? 0;
  }

  /// Count active bills
  Future<int> countActiveBills() async {
    return countBillsByStatus('active');
  }

  /// Count bills by status
  Future<int> countBillsByStatus(String status) async {
    final query = selectOnly(bills)
      ..addColumns([bills.id.count()])
      ..where(bills.status.equals(status))
      ..where(bills.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(bills.id.count()) ?? 0;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get bill versions
  Future<List<BillEntity>> getBillVersions(int billId) {
    return (select(bills)
          ..where((t) => t.id.equals(billId) | t.previousVersionId.equals(billId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of a bill
  Future<int> createBillVersion(int existingBillId, BillsCompanion updates) async {
    final existing = await getBillById(existingBillId);
    if (existing == null) throw Exception('Bill not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingBillId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(bills).insert(newVersion);
  }

  Future<List<BillEntity>> getAllVersionsForBill(int billId) {
    return (select(bills)
      ..where((b) =>
      b.id.equals(billId) |
      b.previousVersionId.equals(billId)))
        .get();
  }

}

