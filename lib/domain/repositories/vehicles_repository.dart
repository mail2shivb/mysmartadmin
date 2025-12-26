import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for vehicle operations
/// 
/// Thin layer above vehiclesDao - delegates to existing DAO methods
class VehiclesRepository {
  final AppDatabase _database;

  VehiclesRepository(this._database);

  /// Add a new vehicle
  Future<int> addVehicle({
    required String vehicleName,
    required String make,
    required String model,
    required String vehicleType,
    required String ownership,
    String? registrationNumber,
    int? yearManufactured,
    String? fuelType,
    int? currentMileage,
    int? currentValueCents,
    DateTime? purchaseDate,
    DateTime? motExpiryDate,
    DateTime? taxExpiryDate,
    DateTime? insuranceExpiryDate,
    bool isDaily = false,
  }) {
    return _database.vehiclesDao.createVehicle(
      VehiclesCompanion.insert(
        vehicleName: vehicleName,
        make: make,
        model: model,
        vehicleType: vehicleType,
        ownership: ownership,
        registrationNumber: Value(registrationNumber),
        yearManufactured: Value(yearManufactured),
        fuelType: Value(fuelType),
        currentMileage: Value(currentMileage),
        currentValueCents: Value(currentValueCents),
        purchaseDate: Value(purchaseDate),
        motExpiryDate: Value(motExpiryDate),
        taxExpiryDate: Value(taxExpiryDate),
        insuranceExpiryDate: Value(insuranceExpiryDate),
        isDaily: Value(isDaily),
      ),
    );
  }

  /// Stream all vehicles (excluding soft deleted)
  Stream<List<VehicleEntity>> watchAllVehicles() {
    return _database.vehiclesDao.watchAllVehicles();
  }

  /// Get a single vehicle by ID
  Future<VehicleEntity?> getVehicleById(int id) {
    return _database.vehiclesDao.getVehicleById(id);
  }

  /// Update an existing vehicle
  Future<bool> updateVehicle(VehicleEntity vehicle) {
    return _database.vehiclesDao.updateVehicle(vehicle);
  }

  /// Soft delete a vehicle (can be restored later)
  Future<int> softDeleteVehicle(int id) {
    return _database.vehiclesDao.softDeleteVehicle(id);
  }
}

