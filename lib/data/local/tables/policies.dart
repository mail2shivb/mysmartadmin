import 'package:drift/drift.dart';
import 'documents.dart';

/// Policies table - insurance policies (home, vehicle, life, travel, etc.)
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('PolicyEntity')
class Policies extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - link to policy document
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();

  // Policy details
  TextColumn get policyNumber => text().withLength(min: 1, max: 255)();
  TextColumn get policyName => text()();
  TextColumn get policyType => text()(); // 'home', 'vehicle', 'life', 'travel', 'health', etc.
  TextColumn get provider => text()(); // Insurance company name

  // Coverage
  TextColumn get coverageType => text().nullable()(); // 'buildings', 'contents', 'comprehensive', etc.
  IntColumn get coverageAmountCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Premium (stored as INTEGER in smallest currency unit)
  IntColumn get premiumAmountCents => integer()();
  TextColumn get premiumFrequency => text()(); // 'monthly', 'annual'

  // Dates
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get renewalDate => dateTime()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get cancellationDate => dateTime().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'expired', 'cancelled'
  BoolColumn get autoRenew => boolean().withDefault(const Constant(true))();

  // Additional details
  IntColumn get excessAmountCents => integer().nullable()(); // Deductible
  TextColumn get beneficiaries => text().nullable()(); // JSON array
  TextColumn get coverageDetails => text().nullable()(); // JSON with detailed coverage info

  // Contact
  TextColumn get providerPhone => text().nullable()();
  TextColumn get providerEmail => text().nullable()();
  TextColumn get claimPhone => text().nullable()();

  // Metadata (JSON)
  TextColumn get metadata => text().nullable()();

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Policies, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

