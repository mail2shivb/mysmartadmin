import 'package:drift/drift.dart';
import 'documents.dart';
import 'properties.dart';
import 'vehicles.dart';

/// Compliance Records table - legal and regulatory compliance tracking
/// Covers: MOT, Gas Safety, EPC, Electrical Safety, etc.
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('ComplianceRecordEntity')
class ComplianceRecords extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign keys - link to related entities
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();
  IntColumn get propertyId => integer().nullable().references(Properties, #id, onDelete: KeyAction.setNull)();
  IntColumn get vehicleId => integer().nullable().references(Vehicles, #id, onDelete: KeyAction.setNull)();

  // Compliance details
  TextColumn get complianceType => text()(); // 'MOT', 'Gas Safety', 'EPC', 'Electrical Safety', 'PAT Test', etc.
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get certificateNumber => text().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('valid'))(); // 'valid', 'expired', 'due', 'failed'
  TextColumn get result => text().nullable()(); // 'pass', 'fail', 'advisory', 'warning'

  // Dates
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();

  // Provider details
  TextColumn get providerName => text().nullable()();
  TextColumn get providerPhone => text().nullable()();
  TextColumn get providerEmail => text().nullable()();
  TextColumn get certificateIssuedBy => text().nullable()();

  // Financial (stored as INTEGER in smallest currency unit)
  IntColumn get costCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Additional details (JSON)
  TextColumn get findings => text().nullable()(); // JSON array of findings/advisories
  TextColumn get metadata => text().nullable()(); // Additional compliance-specific data

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

