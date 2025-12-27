import 'package:drift/drift.dart';
import 'documents.dart';

/// HomeAssets table - appliances, electronics, furniture with warranties
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('HomeAssetEntity')
class HomeAssets extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - link to receipts, manuals, warranties
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();

  // Asset identification
  TextColumn get assetName => text().withLength(min: 1, max: 255)();
  TextColumn get assetType => text()(); // 'appliance', 'electronics', 'furniture', 'tool', 'garden'
  TextColumn get category => text()(); // 'white_goods', 'tv_audio', 'computing', 'kitchen', etc.
  
  // Make & Model
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNumber => text().nullable()();

  // Purchase details
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get purchasePriceCents => integer().nullable()();
  IntColumn get currentValueCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();
  TextColumn get retailer => text().nullable()();

  // Location
  TextColumn get room => text().nullable()(); // 'kitchen', 'living_room', 'bedroom', etc.
  TextColumn get location => text().nullable()(); // Specific location detail

  // Warranty & Insurance
  BoolColumn get hasWarranty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get warrantyStartDate => dateTime().nullable()();
  DateTimeColumn get warrantyExpiryDate => dateTime().nullable()();
  IntColumn get warrantyDurationMonths => integer().nullable()();
  TextColumn get warrantyProvider => text().nullable()();
  BoolColumn get isInsured => boolean().withDefault(const Constant(false))();

  // Service & Maintenance
  DateTimeColumn get lastServiceDate => dateTime().nullable()();
  DateTimeColumn get nextServiceDue => dateTime().nullable()();
  IntColumn get serviceCostCents => integer().nullable()();
  TextColumn get serviceProvider => text().nullable()();

  // Lifecycle
  IntColumn get expectedLifespanYears => integer().nullable()();
  DateTimeColumn get disposalDate => dateTime().nullable()();
  TextColumn get disposalMethod => text().nullable()(); // 'sold', 'donated', 'recycled', 'binned'

  // Energy & Specifications
  TextColumn get energyRating => text().nullable()(); // 'A+++', 'A++', 'A', 'B', etc.
  TextColumn get specifications => text().nullable()(); // JSON for technical specs

  // Contact
  TextColumn get manufacturerPhone => text().nullable()();
  TextColumn get manufacturerWebsite => text().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'faulty', 'disposed', 'sold'
  BoolColumn get needsReplacement => boolean().withDefault(const Constant(false))();

  // Additional details (JSON)
  TextColumn get metadata => text().nullable()(); // Installation notes, accessories, manuals, etc.

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}



