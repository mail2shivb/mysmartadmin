import 'package:drift/drift.dart';

/// Documents — central user record for all document artefacts.
///
/// Storage model (B6.4):
///   Zone A  — normalised columns queried by reports / reminders / filters.
///   Zone B  — [extraFieldsJson] single JSON object, stable taxonomy field IDs as keys.
///
/// Taxonomy IDs are stored as plain TEXT strings. No foreign key to a taxonomy
/// table exists; the taxonomy is shipped reference data validated at the app layer.
@DataClassName('DocumentEntity')
class Documents extends Table {
  // ── Identity ──────────────────────────────────────────────────────────────

  IntColumn get id => integer().autoIncrement()();

  // ── Taxonomy classification (strings only, no FK) ─────────────────────────

  /// Canonical document type ID (e.g. 'passport', 'mot_certificate').
  /// Null when classificationState is 'classification_pending'.
  TextColumn get documentTypeId => text().nullable()();

  /// Cached category ID (e.g. 'travel_immigration'). Set at classification time.
  TextColumn get categoryId => text().nullable()();

  /// Cached domain ID (e.g. 'identity_legal'). Set at classification time.
  TextColumn get domainId => text().nullable()();

  /// Taxonomy version active when this document was classified.
  IntColumn get taxonomyVersion => integer().nullable()();

  /// 'classified' | 'classification_pending'
  TextColumn get classificationState =>
      text().withDefault(const Constant('classification_pending'))();

  // ── User-facing core ──────────────────────────────────────────────────────

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();

  // ── Zone A — normalised fields (used by reports / reminders / filters) ────

  /// Issuer, provider, or authority (e.g. 'DVLA', 'Barclays', 'NHS').
  TextColumn get issuer => text().nullable()();

  /// Reference / policy / account / licence number.
  TextColumn get referenceNumber => text().nullable()();

  /// Monetary value in smallest currency unit (pence/cents).
  IntColumn get amountCents => integer().nullable()();
  TextColumn get currency => text().nullable().withDefault(const Constant('GBP'))();

  /// Date printed on or associated with the document.
  DateTimeColumn get issueDate => dateTime().nullable()();

  /// Hard expiry date — drives expiry_date reminder trigger.
  DateTimeColumn get expiryDate => dateTime().nullable()();

  /// Renewal due date — drives renewal_date reminder trigger.
  DateTimeColumn get renewalDate => dateTime().nullable()();

  /// Scheduled review date — drives review_date reminder trigger.
  DateTimeColumn get reviewDate => dateTime().nullable()();

  /// Next payment due — drives payment_due_date reminder trigger.
  DateTimeColumn get paymentDueDate => dateTime().nullable()();

  // ── Zone B — flexible JSON (type-specific details, not queried) ───────────

  /// JSON object keyed by stable taxonomy field IDs. Values are primitives only.
  /// Unknown keys from future taxonomy versions are preserved untouched.
  TextColumn get extraFieldsJson => text().nullable()();

  // ── OCR provenance ────────────────────────────────────────────────────────

  /// 'manual' | 'ocr' | 'imported'
  TextColumn get source =>
      text().withDefault(const Constant('manual'))();

  /// OCR classification confidence 0.0–1.0. Null for manual entries.
  RealColumn get ocrConfidence => real().nullable()();

  /// Raw OCR extracted text — indexed by FTS.
  TextColumn get ocrText => text().nullable()();

  DateTimeColumn get ocrProcessedAt => dateTime().nullable()();

  // ── File linkage (filesystem path, not blob) ──────────────────────────────

  /// Relative path under the app documents directory.
  TextColumn get filePath => text().nullable()();

  /// MIME type (e.g. 'application/pdf', 'image/jpeg').
  TextColumn get fileMime => text().nullable()();

  IntColumn get fileSizeBytes => integer().nullable()();

  /// SHA-256 hash for duplicate detection.
  TextColumn get fileHash => text().nullable()();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  DateTimeColumn get deletedAt => dateTime().nullable()();

  // ── Versioning ────────────────────────────────────────────────────────────

  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId =>
      integer().nullable().references(Documents, #id)();

  // ── Audit ─────────────────────────────────────────────────────────────────

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
