import 'package:drift/drift.dart';
import 'documents.dart';

/// Subscriptions table - digital and lifestyle subscriptions
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('SubscriptionEntity')
class Subscriptions extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - link to document (e.g., contract, receipt)
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();

  // Subscription details
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // 'streaming', 'mobile', 'gym', 'cloud_storage', etc.
  TextColumn get provider => text().nullable()();

  // Amounts (stored as INTEGER in smallest currency unit)
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // Billing
  TextColumn get billingFrequency => text()(); // 'monthly', 'annual'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get renewalDate => dateTime()();
  DateTimeColumn get cancellationDate => dateTime().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'trial', 'cancelled', 'expired'
  BoolColumn get autoRenew => boolean().withDefault(const Constant(true))();

  // Trial info
  BoolColumn get isTrial => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trialEndDate => dateTime().nullable()();

  // Account details
  TextColumn get accountEmail => text().nullable()();
  TextColumn get accountId => text().nullable()();

  // Usage tracking (optional)
  DateTimeColumn get lastUsedDate => dateTime().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))(); // User-tracked usage

  // Metadata (JSON)
  TextColumn get metadata => text().nullable()();

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Subscriptions, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

