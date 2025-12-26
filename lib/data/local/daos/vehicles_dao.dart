import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vehicles.dart';

part 'vehicles_dao.g.dart';

/// Data Access Object for Vehicles
/// 
/// Manages vehicles (cars, motorcycles, EVs, etc.)
@DriftAccessor(tables: [Vehicles])
class VehiclesDao extends DatabaseAccessor<AppDatabase> with _$VehiclesDaoMixin {
  VehiclesDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new vehicle
  Future<int> createVehicle(VehiclesCompanion vehicle) {
    return into(vehicles).insert(vehicle);
  }

  /// Create multiple vehicles
  Future<void> createVehicles(List<VehiclesCompanion> vehicleList) async {
    await batch((batch) {
      batch.insertAll(vehicles, vehicleList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a vehicle by ID
  Future<VehicleEntity?> getVehicleById(int id) {
    return (select(vehicles)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all vehicles
  Future<List<VehicleEntity>> getAllVehicles() {
    return (select(vehicles)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isDaily)]))
        .get();
  }

  /// Get vehicle by registration number
  Future<VehicleEntity?> getVehicleByRegistration(String registration) {
    return (select(vehicles)
          ..where((t) => t.registrationNumber.equals(registration))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get vehicles by type
  Future<List<VehicleEntity>> getVehiclesByType(String vehicleType) {
    return (select(vehicles)
          ..where((t) => t.vehicleType.equals(vehicleType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get vehicles by status
  Future<List<VehicleEntity>> getVehiclesByStatus(String status) {
    return (select(vehicles)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get active vehicles
  Future<List<VehicleEntity>> getActiveVehicles() {
    return getVehiclesByStatus('active');
  }

  /// Get daily driver vehicles
  Future<List<VehicleEntity>> getDailyDrivers() {
    return (select(vehicles)
          ..where((t) => t.isDaily.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get vehicles by make
  Future<List<VehicleEntity>> getVehiclesByMake(String make) {
    return (select(vehicles)
          ..where((t) => t.make.equals(make))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get vehicles by ownership type
  Future<List<VehicleEntity>> getVehiclesByOwnership(String ownership) {
    return (select(vehicles)
          ..where((t) => t.ownership.equals(ownership))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get vehicles with expiring MOT (within days)
  Future<List<VehicleEntity>> getVehiclesWithExpiringMOT(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(vehicles)
          ..where((t) => t.motExpiryDate.isSmallerThanValue(cutoffDate))
          ..where((t) => t.motExpiryDate.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.motExpiryDate)]))
        .get();
  }

  /// Get vehicles with expiring tax (within days)
  Future<List<VehicleEntity>> getVehiclesWithExpiringTax(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(vehicles)
          ..where((t) => t.taxExpiryDate.isSmallerThanValue(cutoffDate))
          ..where((t) => t.taxExpiryDate.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.taxExpiryDate)]))
        .get();
  }

  /// Get vehicles with expiring insurance (within days)
  Future<List<VehicleEntity>> getVehiclesWithExpiringInsurance(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(vehicles)
          ..where((t) => t.insuranceExpiryDate.isSmallerThanValue(cutoffDate))
          ..where((t) => t.insuranceExpiryDate.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.insuranceExpiryDate)]))
        .get();
  }

  /// Get vehicles needing service (by date or mileage)
  Future<List<VehicleEntity>> getVehiclesNeedingService() async {
    final now = DateTime.now();
    final allVehicles = await (select(vehicles)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    
    // Filter vehicles that need service by date OR mileage
    return allVehicles.where((v) {
      final needsServiceByDate = v.nextServiceDue != null && v.nextServiceDue!.isBefore(now);
      final needsServiceByMileage = v.nextServiceMileage != null && 
                                     v.currentMileage != null && 
                                     v.currentMileage! >= v.nextServiceMileage!;
      return needsServiceByDate || needsServiceByMileage;
    }).toList()..sort((a, b) {
      if (a.nextServiceDue == null) return 1;
      if (b.nextServiceDue == null) return -1;
      return a.nextServiceDue!.compareTo(b.nextServiceDue!);
    });
  }

  /// Get vehicles by fuel type
  Future<List<VehicleEntity>> getVehiclesByFuelType(String fuelType) {
    return (select(vehicles)
          ..where((t) => t.fuelType.equals(fuelType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get electric vehicles
  Future<List<VehicleEntity>> getElectricVehicles() {
    return (select(vehicles)
          ..where((t) => t.fuelType.equals('electric') | t.fuelType.equals('hybrid'))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Stream all vehicles
  Stream<List<VehicleEntity>> watchAllVehicles() {
    return (select(vehicles)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isDaily)]))
        .watch();
  }

  /// Stream vehicles by status
  Stream<List<VehicleEntity>> watchVehiclesByStatus(String status) {
    return (select(vehicles)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a vehicle
  Future<bool> updateVehicle(VehicleEntity vehicle) {
    return update(vehicles).replace(vehicle);
  }

  /// Update mileage
  Future<int> updateMileage(int id, int mileage) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        currentMileage: Value(mileage),
        lastMileageUpdate: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update vehicle value
  Future<int> updateVehicleValue(int id, int valueCents) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        currentValueCents: Value(valueCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update finance balance
  Future<int> updateFinanceBalance(int id, int balanceCents) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        financeBalanceCents: Value(balanceCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update MOT expiry
  Future<int> updateMOTExpiry(int id, DateTime expiryDate) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        motExpiryDate: Value(expiryDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update tax expiry
  Future<int> updateTaxExpiry(int id, DateTime expiryDate) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        taxExpiryDate: Value(expiryDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update insurance expiry
  Future<int> updateInsuranceExpiry(int id, DateTime expiryDate) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        insuranceExpiryDate: Value(expiryDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Record service
  Future<int> recordService(int id, DateTime serviceDate, {DateTime? nextServiceDue, int? nextServiceMileage}) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        lastServiceDate: Value(serviceDate),
        nextServiceDue: Value(nextServiceDue),
        nextServiceMileage: Value(nextServiceMileage),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update vehicle status
  Future<int> updateVehicleStatus(int id, String status) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark vehicle as sold
  Future<int> markVehicleAsSold(int id) {
    return updateVehicleStatus(id, 'sold');
  }

  /// Set as daily driver
  Future<void> setDailyDriver(int id) async {
    // First, unset all other vehicles
    await (update(vehicles)..where((t) => t.deletedAt.isNull())).write(
      const VehiclesCompanion(
        isDaily: Value(false),
      ),
    );
    // Then set the selected vehicle as daily driver
    await (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        isDaily: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a vehicle
  Future<int> softDeleteVehicle(int id) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      VehiclesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a vehicle
  Future<int> hardDeleteVehicle(int id) {
    return (delete(vehicles)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted vehicle
  Future<int> restoreVehicle(int id) {
    return (update(vehicles)..where((t) => t.id.equals(id))).write(
      const VehiclesCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total vehicle value
  Future<int> calculateTotalVehicleValue() async {
    final allVehicles = await getActiveVehicles();
    int total = 0;
    for (final vehicle in allVehicles) {
      if (vehicle.currentValueCents != null) {
        total += vehicle.currentValueCents!;
      }
    }
    return total;
  }

  /// Calculate total finance debt
  Future<int> calculateTotalFinanceDebt() async {
    final allVehicles = await getActiveVehicles();
    int total = 0;
    for (final vehicle in allVehicles) {
      if (vehicle.financeBalanceCents != null) {
        total += vehicle.financeBalanceCents!;
      }
    }
    return total;
  }

  /// Calculate total monthly finance payments
  Future<int> calculateMonthlyFinancePayments() async {
    final allVehicles = await getActiveVehicles();
    int total = 0;
    for (final vehicle in allVehicles) {
      if (vehicle.monthlyPaymentCents != null) {
        total += vehicle.monthlyPaymentCents!;
      }
    }
    return total;
  }

  /// Count vehicles by type
  Future<int> countVehiclesByType(String vehicleType) async {
    final query = selectOnly(vehicles)
      ..addColumns([vehicles.id.count()])
      ..where(vehicles.vehicleType.equals(vehicleType))
      ..where(vehicles.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(vehicles.id.count()) ?? 0;
  }

  /// Count vehicles by status
  Future<int> countVehiclesByStatus(String status) async {
    final query = selectOnly(vehicles)
      ..addColumns([vehicles.id.count()])
      ..where(vehicles.status.equals(status))
      ..where(vehicles.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(vehicles.id.count()) ?? 0;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get vehicle versions
  Future<List<VehicleEntity>> getVehicleVersions(int vehicleId) {
    return (select(vehicles)
          ..where((t) => t.id.equals(vehicleId) | t.previousVersionId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of a vehicle
  Future<int> createVehicleVersion(int existingVehicleId, VehiclesCompanion updates) async {
    final existing = await getVehicleById(existingVehicleId);
    if (existing == null) throw Exception('Vehicle not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingVehicleId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(vehicles).insert(newVersion);
  }
}

