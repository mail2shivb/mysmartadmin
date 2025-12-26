import 'package:drift/drift.dart';

/// Documents table - core entity for storing all document metadata
/// Supports soft delete and versioning patterns
@DataClassName('DocumentEntity')
class Documents extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Core fields
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get documentType => text()(); // e.g., 'passport', 'bill', 'policy'
  TextColumn get category => text()(); // Domain category (property, vehicle, finance, etc.)

  // File storage
  TextColumn get filePath => text().nullable()(); // Local file path
  TextColumn get fileType => text().nullable()(); // mime type or extension
  IntColumn get fileSizeBytes => integer().nullable()();

  // OCR & Extracted Data (JSON column)
  TextColumn get extractedData => text().nullable()(); // JSON string

  // Tags for search
  TextColumn get tags => text().nullable()(); // Comma-separated or JSON array

  // Dates
  DateTimeColumn get documentDate => dateTime().nullable()(); // Date on the document
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get reminderDate => dateTime().nullable()();

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Versioning
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId => integer().nullable().references(Documents, #id)();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

