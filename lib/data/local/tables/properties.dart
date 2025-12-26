import 'package:drift/drift.dart';
import 'documents.dart';

/// Properties table - owned and rented properties
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('PropertyEntity')
class Properties extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - link to property documents (deeds, mortgage, etc.)
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();

  // Property details
  TextColumn get propertyName => text().withLength(min: 1, max: 255)();
  TextColumn get propertyType => text()(); // 'house', 'flat', 'bungalow', 'land', etc.
  TextColumn get ownership => text()(); // 'owned', 'mortgaged', 'rented', 'leasehold'
  
  // Address
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get city => text()();
  TextColumn get county => text().nullable()();
  TextColumn get postcode => text()();
  TextColumn get country => text().withDefault(const Constant('UK'))();

  // Property characteristics
  IntColumn get bedrooms => integer().nullable()();
  IntColumn get bathrooms => integer().nullable()();
  RealColumn get squareMetres => real().nullable()();
  TextColumn get councilTaxBand => text().nullable()(); // 'A', 'B', 'C', etc.

  // Financial (stored as INTEGER in smallest currency unit)
  IntColumn get purchasePriceCents => integer().nullable()();
  IntColumn get currentValueCents => integer().nullable()();
  IntColumn get mortgageBalanceCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Dates
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get moveInDate => dateTime().nullable()();
  DateTimeColumn get moveOutDate => dateTime().nullable()();
  DateTimeColumn get lastValuationDate => dateTime().nullable()();

  // Lease details (for leasehold/rented)
  DateTimeColumn get leaseStartDate => dateTime().nullable()();
  DateTimeColumn get leaseEndDate => dateTime().nullable()();
  IntColumn get leaseYearsRemaining => integer().nullable()();

  // Contact details
  TextColumn get landlordName => text().nullable()();
  TextColumn get landlordPhone => text().nullable()();
  TextColumn get landlordEmail => text().nullable()();
  TextColumn get estatAgentName => text().nullable()();
  TextColumn get estatAgentPhone => text().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'sold', 'let', 'vacant'
  BoolColumn get isPrimaryResidence => boolean().withDefault(const Constant(false))();

  // Additional details (JSON)
  TextColumn get metadata => text().nullable()(); // Energy rating, parking, garden, etc.

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Properties, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

