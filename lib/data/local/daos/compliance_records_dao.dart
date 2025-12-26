import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/compliance_records.dart';

part 'compliance_records_dao.g.dart';

/// Data Access Object for Compliance Records
/// 
/// Manages compliance records (MOT, Gas Safety, EPC, etc.)
@DriftAccessor(tables: [ComplianceRecords])
class ComplianceRecordsDao extends DatabaseAccessor<AppDatabase> with _$ComplianceRecordsDaoMixin {
  ComplianceRecordsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new compliance record
  Future<int> createComplianceRecord(ComplianceRecordsCompanion record) {
    return into(complianceRecords).insert(record);
  }

  /// Create multiple compliance records
  Future<void> createComplianceRecords(List<ComplianceRecordsCompanion> recordList) async {
    await batch((batch) {
      batch.insertAll(complianceRecords, recordList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a compliance record by ID
  Future<ComplianceRecordEntity?> getComplianceRecordById(int id) {
    return (select(complianceRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all compliance records
  Future<List<ComplianceRecordEntity>> getAllComplianceRecords() {
    return (select(complianceRecords)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.expiryDate)]))
        .get();
  }

  /// Get compliance records by type
  Future<List<ComplianceRecordEntity>> getComplianceRecordsByType(String complianceType) {
    return (select(complianceRecords)
          ..where((t) => t.complianceType.equals(complianceType))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .get();
  }

  /// Get compliance records by status
  Future<List<ComplianceRecordEntity>> getComplianceRecordsByStatus(String status) {
    return (select(complianceRecords)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.expiryDate)]))
        .get();
  }

  /// Get valid compliance records
  Future<List<ComplianceRecordEntity>> getValidComplianceRecords() {
    return getComplianceRecordsByStatus('valid');
  }

  /// Get expired compliance records
  Future<List<ComplianceRecordEntity>> getExpiredComplianceRecords() {
    return getComplianceRecordsByStatus('expired');
  }

  /// Get compliance records expiring soon (within days)
  Future<List<ComplianceRecordEntity>> getComplianceRecordsExpiringSoon(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(complianceRecords)
          ..where((t) => t.expiryDate.isSmallerThanValue(cutoffDate))
          ..where((t) => t.expiryDate.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.expiryDate)]))
        .get();
  }

  /// Get compliance records for a property
  Future<List<ComplianceRecordEntity>> getComplianceRecordsForProperty(int propertyId) {
    return (select(complianceRecords)
          ..where((t) => t.propertyId.equals(propertyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .get();
  }

  /// Get compliance records for a vehicle
  Future<List<ComplianceRecordEntity>> getComplianceRecordsForVehicle(int vehicleId) {
    return (select(complianceRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .get();
  }

  /// Get compliance records by certificate number
  Future<ComplianceRecordEntity?> getComplianceRecordByCertificateNumber(String certificateNumber) {
    return (select(complianceRecords)
          ..where((t) => t.certificateNumber.equals(certificateNumber))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get compliance records due this month
  Future<List<ComplianceRecordEntity>> getComplianceRecordsDueThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return (select(complianceRecords)
          ..where((t) => t.nextDueDate.isBiggerOrEqualValue(startOfMonth))
          ..where((t) => t.nextDueDate.isSmallerOrEqualValue(endOfMonth))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
  }

  /// Stream all compliance records
  Stream<List<ComplianceRecordEntity>> watchAllComplianceRecords() {
    return (select(complianceRecords)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.expiryDate)]))
        .watch();
  }

  /// Stream compliance records by status
  Stream<List<ComplianceRecordEntity>> watchComplianceRecordsByStatus(String status) {
    return (select(complianceRecords)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.expiryDate)]))
        .watch();
  }

  /// Stream compliance records for a property
  Stream<List<ComplianceRecordEntity>> watchComplianceRecordsForProperty(int propertyId) {
    return (select(complianceRecords)
          ..where((t) => t.propertyId.equals(propertyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .watch();
  }

  /// Stream compliance records for a vehicle
  Stream<List<ComplianceRecordEntity>> watchComplianceRecordsForVehicle(int vehicleId) {
    return (select(complianceRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a compliance record
  Future<bool> updateComplianceRecord(ComplianceRecordEntity record) {
    return update(complianceRecords).replace(record);
  }

  /// Update compliance record status
  Future<int> updateComplianceRecordStatus(int id, String status) {
    return (update(complianceRecords)..where((t) => t.id.equals(id))).write(
      ComplianceRecordsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update expiry date
  Future<int> updateExpiryDate(int id, DateTime expiryDate) {
    return (update(complianceRecords)..where((t) => t.id.equals(id))).write(
      ComplianceRecordsCompanion(
        expiryDate: Value(expiryDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark as expired
  Future<int> markAsExpired(int id) {
    return updateComplianceRecordStatus(id, 'expired');
  }

  /// Mark as due
  Future<int> markAsDue(int id) {
    return updateComplianceRecordStatus(id, 'due');
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a compliance record
  Future<int> softDeleteComplianceRecord(int id) {
    return (update(complianceRecords)..where((t) => t.id.equals(id))).write(
      ComplianceRecordsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a compliance record
  Future<int> hardDeleteComplianceRecord(int id) {
    return (delete(complianceRecords)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted compliance record
  Future<int> restoreComplianceRecord(int id) {
    return (update(complianceRecords)..where((t) => t.id.equals(id))).write(
      const ComplianceRecordsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count compliance records by type
  Future<int> countComplianceRecordsByType(String complianceType) async {
    final query = selectOnly(complianceRecords)
      ..addColumns([complianceRecords.id.count()])
      ..where(complianceRecords.complianceType.equals(complianceType))
      ..where(complianceRecords.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(complianceRecords.id.count()) ?? 0;
  }

  /// Count compliance records by status
  Future<int> countComplianceRecordsByStatus(String status) async {
    final query = selectOnly(complianceRecords)
      ..addColumns([complianceRecords.id.count()])
      ..where(complianceRecords.status.equals(status))
      ..where(complianceRecords.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(complianceRecords.id.count()) ?? 0;
  }

  /// Calculate total compliance costs
  Future<int> calculateTotalComplianceCosts() async {
    final allRecords = await getAllComplianceRecords();
    int total = 0;
    for (final record in allRecords) {
      if (record.costCents != null) {
        total += record.costCents!;
      }
    }
    return total;
  }

  /// Calculate annual compliance costs (last 12 months)
  Future<int> calculateAnnualComplianceCosts() async {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    
    final recentRecords = await (select(complianceRecords)
          ..where((t) => t.issueDate.isBiggerOrEqualValue(oneYearAgo))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    
    int total = 0;
    for (final record in recentRecords) {
      if (record.costCents != null) {
        total += record.costCents!;
      }
    }
    return total;
  }
}

