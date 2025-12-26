import 'package:drift/drift.dart';
import 'documents.dart';
import 'policies.dart';
import 'properties.dart';
import 'vehicles.dart';

/// Claims table - insurance and warranty claims tracking
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('ClaimEntity')
class Claims extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign keys - link to related entities
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();
  IntColumn get policyId => integer().nullable().references(Policies, #id, onDelete: KeyAction.setNull)();
  IntColumn get propertyId => integer().nullable().references(Properties, #id, onDelete: KeyAction.setNull)();
  IntColumn get vehicleId => integer().nullable().references(Vehicles, #id, onDelete: KeyAction.setNull)();

  // Claim details
  TextColumn get claimNumber => text().withLength(min: 1, max: 255)();
  TextColumn get claimType => text()(); // 'insurance', 'warranty', 'refund', 'compensation'
  TextColumn get category => text().nullable()(); // 'property', 'vehicle', 'health', 'travel', 'appliance', etc.
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();

  // Status tracking
  TextColumn get status => text().withDefault(const Constant('submitted'))(); // 'draft', 'submitted', 'under_review', 'approved', 'rejected', 'paid', 'closed'
  TextColumn get outcome => text().nullable()(); // 'approved', 'partial', 'rejected', 'withdrawn'

  // Dates
  DateTimeColumn get incidentDate => dateTime()();
  DateTimeColumn get submittedDate => dateTime().nullable()();
  DateTimeColumn get approvedDate => dateTime().nullable()();
  DateTimeColumn get paidDate => dateTime().nullable()();
  DateTimeColumn get closedDate => dateTime().nullable()();

  // Financial (stored as INTEGER in smallest currency unit)
  IntColumn get claimedAmountCents => integer().nullable()();
  IntColumn get approvedAmountCents => integer().nullable()();
  IntColumn get paidAmountCents => integer().nullable()();
  IntColumn get excessPaidCents => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Provider/insurer details
  TextColumn get providerName => text().nullable()();
  TextColumn get providerPhone => text().nullable()();
  TextColumn get providerEmail => text().nullable()();
  TextColumn get claimHandlerName => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();

  // Supporting information (JSON)
  TextColumn get evidenceDocuments => text().nullable()(); // JSON array of document IDs
  TextColumn get notes => text().nullable()(); // Timeline of interactions/notes

  // Additional details (JSON)
  TextColumn get metadata => text().nullable()(); // Additional claim-specific data

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Claims, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

