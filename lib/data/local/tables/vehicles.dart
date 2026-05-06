import 'package:drift/drift.dart';

/// Vehicles table - cars, motorcycles, bikes, EVs
/// Monetary values stored as INTEGER (cents/pence)
///
/// Documents attach to vehicles via the [Relationships] table (B6.4).
/// No direct document_id FK — use relationship_type_id = 'vehicle_policy'
/// or the generic [Relationships] entity for other document ↔ vehicle links.
@DataClassName('VehicleEntity')
class Vehicles extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Vehicle identification
  TextColumn get vehicleName => text().withLength(min: 1, max: 255)(); // Friendly name
  TextColumn get vehicleType => text()(); // 'car', 'motorcycle', 'van', 'bicycle', 'ev'
  TextColumn get registrationNumber => text().nullable()(); // UK reg plate
  TextColumn get vin => text().nullable()(); // Vehicle Identification Number

  // Make & Model
  TextColumn get make => text()(); // 'Ford', 'BMW', 'Tesla', etc.
  TextColumn get model => text()();
  TextColumn get variant => text().nullable()(); // Trim level
  IntColumn get yearManufactured => integer().nullable()();
  TextColumn get colour => text().nullable()();

  // Engine & Technical
  TextColumn get fuelType => text().nullable()(); // 'petrol', 'diesel', 'electric', 'hybrid'
  IntColumn get engineSizeCC => integer().nullable()();
  IntColumn get batteryCapacityKWh => integer().nullable()(); // For EVs
  TextColumn get transmission => text().nullable()(); // 'manual', 'automatic'

  // Ownership & Finance
  TextColumn get ownership => text()(); // 'owned', 'financed', 'leased', 'pcp', 'hp'
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get purchasePriceCents => integer().nullable()();
  IntColumn get currentValueCents => integer().nullable()();
  IntColumn get financeBalanceCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Mileage
  IntColumn get currentMileage => integer().nullable()();
  DateTimeColumn get lastMileageUpdate => dateTime().nullable()();
  IntColumn get annualMileageEstimate => integer().nullable()();

  // Legal & Compliance
  DateTimeColumn get motExpiryDate => dateTime().nullable()();
  DateTimeColumn get taxExpiryDate => dateTime().nullable()();
  DateTimeColumn get insuranceExpiryDate => dateTime().nullable()();

  // Service & Maintenance
  DateTimeColumn get lastServiceDate => dateTime().nullable()();
  DateTimeColumn get nextServiceDue => dateTime().nullable()();
  IntColumn get nextServiceMileage => integer().nullable()();

  // Finance details
  DateTimeColumn get financeEndDate => dateTime().nullable()();
  IntColumn get monthlyPaymentCents => integer().nullable()();
  TextColumn get financeProvider => text().nullable()();

  // Contact details
  TextColumn get dealerName => text().nullable()();
  TextColumn get dealerPhone => text().nullable()();
  TextColumn get garagePreference => text().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'sold', 'scrapped', 'stolen'
  BoolColumn get isDaily => boolean().withDefault(const Constant(false))(); // Daily driver?

  // Additional details (JSON)
  TextColumn get metadata => text().nullable()(); // Modifications, accessories, service history, etc.

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Vehicles, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}



