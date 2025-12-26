import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/service_records.dart';

part 'service_records_dao.g.dart';

/// Data Access Object for Service Records
/// 
/// Manages service records (vehicle services, repairs, maintenance, etc.)
@DriftAccessor(tables: [ServiceRecords])
class ServiceRecordsDao extends DatabaseAccessor<AppDatabase> with _$ServiceRecordsDaoMixin {
  ServiceRecordsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new service record
  Future<int> createServiceRecord(ServiceRecordsCompanion record) {
    return into(serviceRecords).insert(record);
  }

  /// Create multiple service records
  Future<void> createServiceRecords(List<ServiceRecordsCompanion> recordList) async {
    await batch((batch) {
      batch.insertAll(serviceRecords, recordList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a service record by ID
  Future<ServiceRecordEntity?> getServiceRecordById(int id) {
    return (select(serviceRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all service records
  Future<List<ServiceRecordEntity>> getAllServiceRecords() {
    return (select(serviceRecords)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Get service records by type
  Future<List<ServiceRecordEntity>> getServiceRecordsByType(String serviceType) {
    return (select(serviceRecords)
          ..where((t) => t.serviceType.equals(serviceType))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Get service records by status
  Future<List<ServiceRecordEntity>> getServiceRecordsByStatus(String status) {
    return (select(serviceRecords)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Get completed service records
  Future<List<ServiceRecordEntity>> getCompletedServiceRecords() {
    return getServiceRecordsByStatus('completed');
  }

  /// Get scheduled service records
  Future<List<ServiceRecordEntity>> getScheduledServiceRecords() {
    return getServiceRecordsByStatus('scheduled');
  }

  /// Get service records for a property
  Future<List<ServiceRecordEntity>> getServiceRecordsForProperty(int propertyId) {
    return (select(serviceRecords)
          ..where((t) => t.propertyId.equals(propertyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Get service records for a vehicle
  Future<List<ServiceRecordEntity>> getServiceRecordsForVehicle(int vehicleId) {
    return (select(serviceRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Get service records for a home asset
  Future<List<ServiceRecordEntity>> getServiceRecordsForHomeAsset(int homeAssetId) {
    return (select(serviceRecords)
          ..where((t) => t.homeAssetId.equals(homeAssetId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Get service records by work order number
  Future<ServiceRecordEntity?> getServiceRecordByWorkOrderNumber(String workOrderNumber) {
    return (select(serviceRecords)
          ..where((t) => t.workOrderNumber.equals(workOrderNumber))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get service records scheduled this month
  Future<List<ServiceRecordEntity>> getServiceRecordsScheduledThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return (select(serviceRecords)
          ..where((t) => t.scheduledDate.isBiggerOrEqualValue(startOfMonth))
          ..where((t) => t.scheduledDate.isSmallerOrEqualValue(endOfMonth))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)]))
        .get();
  }

  /// Get service records due soon (within days)
  Future<List<ServiceRecordEntity>> getServiceRecordsDueSoon(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(serviceRecords)
          ..where((t) => t.nextServiceDue.isSmallerThanValue(cutoffDate))
          ..where((t) => t.nextServiceDue.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextServiceDue)]))
        .get();
  }

  /// Get warranty-covered service records
  Future<List<ServiceRecordEntity>> getWarrantyCoveredServiceRecords() {
    return (select(serviceRecords)
          ..where((t) => t.isWarrantyCovered.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .get();
  }

  /// Stream all service records
  Stream<List<ServiceRecordEntity>> watchAllServiceRecords() {
    return (select(serviceRecords)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .watch();
  }

  /// Stream service records by status
  Stream<List<ServiceRecordEntity>> watchServiceRecordsByStatus(String status) {
    return (select(serviceRecords)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .watch();
  }

  /// Stream service records for a vehicle
  Stream<List<ServiceRecordEntity>> watchServiceRecordsForVehicle(int vehicleId) {
    return (select(serviceRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.serviceDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a service record
  Future<bool> updateServiceRecord(ServiceRecordEntity record) {
    return update(serviceRecords).replace(record);
  }

  /// Update service record status
  Future<int> updateServiceRecordStatus(int id, String status) {
    return (update(serviceRecords)..where((t) => t.id.equals(id))).write(
      ServiceRecordsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark service as completed
  Future<int> markServiceAsCompleted(int id, DateTime completedDate) {
    return (update(serviceRecords)..where((t) => t.id.equals(id))).write(
      ServiceRecordsCompanion(
        status: const Value('completed'),
        completedDate: Value(completedDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark service as cancelled
  Future<int> markServiceAsCancelled(int id) {
    return updateServiceRecordStatus(id, 'cancelled');
  }

  /// Update scheduled date
  Future<int> updateScheduledDate(int id, DateTime scheduledDate) {
    return (update(serviceRecords)..where((t) => t.id.equals(id))).write(
      ServiceRecordsCompanion(
        scheduledDate: Value(scheduledDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a service record
  Future<int> softDeleteServiceRecord(int id) {
    return (update(serviceRecords)..where((t) => t.id.equals(id))).write(
      ServiceRecordsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a service record
  Future<int> hardDeleteServiceRecord(int id) {
    return (delete(serviceRecords)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted service record
  Future<int> restoreServiceRecord(int id) {
    return (update(serviceRecords)..where((t) => t.id.equals(id))).write(
      const ServiceRecordsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count service records by type
  Future<int> countServiceRecordsByType(String serviceType) async {
    final query = selectOnly(serviceRecords)
      ..addColumns([serviceRecords.id.count()])
      ..where(serviceRecords.serviceType.equals(serviceType))
      ..where(serviceRecords.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(serviceRecords.id.count()) ?? 0;
  }

  /// Count service records by status
  Future<int> countServiceRecordsByStatus(String status) async {
    final query = selectOnly(serviceRecords)
      ..addColumns([serviceRecords.id.count()])
      ..where(serviceRecords.status.equals(status))
      ..where(serviceRecords.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(serviceRecords.id.count()) ?? 0;
  }

  /// Calculate total service costs
  Future<int> calculateTotalServiceCosts() async {
    final allRecords = await getAllServiceRecords();
    int total = 0;
    for (final record in allRecords) {
      if (record.costCents != null) {
        total += record.costCents!;
      }
    }
    return total;
  }

  /// Calculate annual service costs (last 12 months)
  Future<int> calculateAnnualServiceCosts() async {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    
    final recentRecords = await (select(serviceRecords)
          ..where((t) => t.serviceDate.isBiggerOrEqualValue(oneYearAgo))
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

  /// Calculate service costs for a vehicle
  Future<int> calculateServiceCostsForVehicle(int vehicleId) async {
    final records = await getServiceRecordsForVehicle(vehicleId);
    int total = 0;
    for (final record in records) {
      if (record.costCents != null) {
        total += record.costCents!;
      }
    }
    return total;
  }

  /// Calculate warranty savings
  Future<int> calculateWarrantySavings() async {
    final warrantyCovered = await getWarrantyCoveredServiceRecords();
    int total = 0;
    for (final record in warrantyCovered) {
      if (record.costCents != null) {
        total += record.costCents!;
      }
    }
    return total;
  }
}

