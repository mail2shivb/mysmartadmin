import 'package:drift/drift.dart';
import 'documents.dart';
import 'properties.dart';
import 'vehicles.dart';
import 'home_assets.dart';

/// Service Records table - maintenance and service history
/// Covers: Vehicle services, boiler services, appliance repairs, etc.
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('ServiceRecordEntity')
class ServiceRecords extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign keys - link to related entities
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();
  IntColumn get propertyId => integer().nullable().references(Properties, #id, onDelete: KeyAction.setNull)();
  IntColumn get vehicleId => integer().nullable().references(Vehicles, #id, onDelete: KeyAction.setNull)();
  IntColumn get homeAssetId => integer().nullable().references(HomeAssets, #id, onDelete: KeyAction.setNull)();

  // Service details
  TextColumn get serviceType => text()(); // 'routine', 'repair', 'inspection', 'recall', 'warranty', 'emergency'
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get workOrderNumber => text().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('completed'))(); // 'scheduled', 'in_progress', 'completed', 'cancelled'

  // Dates
  DateTimeColumn get serviceDate => dateTime()();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  DateTimeColumn get nextServiceDue => dateTime().nullable()();

  // Provider details
  TextColumn get providerName => text().nullable()();
  TextColumn get providerPhone => text().nullable()();
  TextColumn get providerEmail => text().nullable()();
  TextColumn get technicianName => text().nullable()();

  // Financial (stored as INTEGER in smallest currency unit)
  IntColumn get costCents => integer().nullable()();
  IntColumn get labourCostCents => integer().nullable()();
  IntColumn get partsCostCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();
  BoolColumn get isWarrantyCovered => boolean().withDefault(const Constant(false))();

  // Mileage/usage tracking (for vehicles)
  IntColumn get mileageAtService => integer().nullable()();
  IntColumn get hoursUsed => integer().nullable()(); // For equipment/appliances

  // Parts and work performed (JSON)
  TextColumn get partsReplaced => text().nullable()(); // JSON array of parts
  TextColumn get workPerformed => text().nullable()(); // JSON array of work items

  // Additional details (JSON)
  TextColumn get metadata => text().nullable()(); // Additional service-specific data

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

