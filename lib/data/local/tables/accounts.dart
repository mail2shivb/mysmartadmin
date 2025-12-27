import 'package:drift/drift.dart';
import 'documents.dart';

/// Accounts table - bank accounts, credit cards, loans, savings
/// Monetary values stored as INTEGER (cents/pence)
@DataClassName('AccountEntity')
class Accounts extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign key - link to account documents (statements, agreements, etc.)
  IntColumn get documentId => integer().nullable().references(Documents, #id, onDelete: KeyAction.setNull)();

  // Account details
  TextColumn get accountName => text().withLength(min: 1, max: 255)();
  TextColumn get accountType => text()(); // 'current', 'savings', 'credit_card', 'loan', 'mortgage', 'isa'
  TextColumn get provider => text()(); // Bank/lender name
  TextColumn get accountNumber => text().nullable()();
  TextColumn get sortCode => text().nullable()(); // UK sort code
  TextColumn get iban => text().nullable()();
  TextColumn get swiftBic => text().nullable()();

  // Balances (stored as INTEGER in smallest currency unit)
  IntColumn get currentBalanceCents => integer().withDefault(const Constant(0))();
  IntColumn get availableBalanceCents => integer().nullable()();
  IntColumn get overdraftLimitCents => integer().nullable()();
  IntColumn get creditLimitCents => integer().nullable()(); // For credit cards
  TextColumn get currency => text().withDefault(const Constant('GBP'))();

  // For loans/credit
  IntColumn get originalAmountCents => integer().nullable()(); // Original loan amount
  IntColumn get outstandingBalanceCents => integer().nullable()();
  IntColumn get monthlyPaymentCents => integer().nullable()();
  RealColumn get interestRatePercent => real().nullable()(); // APR
  DateTimeColumn get loanStartDate => dateTime().nullable()();
  DateTimeColumn get loanEndDate => dateTime().nullable()();

  // For savings/investments
  RealColumn get savingsInterestRatePercent => real().nullable()();
  BoolColumn get isIsaAccount => boolean().withDefault(const Constant(false))();
  IntColumn get annualIsaAllowanceCents => integer().nullable()();
  IntColumn get usedIsaAllowanceCents => integer().nullable()();

  // Dates
  DateTimeColumn get openedDate => dateTime().nullable()();
  DateTimeColumn get closedDate => dateTime().nullable()();
  DateTimeColumn get lastUpdated => dateTime().nullable()();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();

  // Direct debits & Standing orders
  IntColumn get directDebitCount => integer().withDefault(const Constant(0))();
  IntColumn get standingOrderCount => integer().withDefault(const Constant(0))();

  // Contact
  TextColumn get providerPhone => text().nullable()();
  TextColumn get providerEmail => text().nullable()();
  TextColumn get branchAddress => text().nullable()();

  // Status
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'closed', 'frozen', 'dormant'
  BoolColumn get isPrimaryAccount => boolean().withDefault(const Constant(false))();
  BoolColumn get isJointAccount => boolean().withDefault(const Constant(false))();

  // Additional details (JSON)
  TextColumn get metadata => text().nullable()(); // Rewards, perks, joint holders, etc.

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Accounts, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}



