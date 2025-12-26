import 'package:drift/drift.dart';
import 'documents.dart';

/// Bills table - recurring and one-off bills/payments
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('BillEntity')
class Bills extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - link to document (e.g., scanned bill)
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();

  // Bill details
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // 'mortgage', 'rent', 'utilities', 'council_tax', etc.
  TextColumn get provider => text().nullable()(); // Company name

  // Amounts (stored as INTEGER in smallest currency unit, e.g., pence/cents)
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Billing cycle
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get frequency => text().nullable()(); // 'monthly', 'quarterly', 'annual'
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  DateTimeColumn get lastPaidDate => dateTime().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'paused', 'cancelled'
  BoolColumn get isAutoPay => boolean().withDefault(const Constant(false))();

  // Account details
  TextColumn get accountNumber => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();

  // Metadata (JSON)
  TextColumn get metadata => text().nullable()(); // Additional flexible data

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Bills, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

