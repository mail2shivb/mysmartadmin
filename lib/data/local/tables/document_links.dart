import 'package:drift/drift.dart';
import 'documents.dart';

/// Document Links table - many-to-many relationships between documents
/// Enables linking related documents (e.g., insurance policy to claims, receipts to warranties)
@DataClassName('DocumentLinkEntity')
class DocumentLinks extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Foreign keys
  IntColumn get sourceDocumentId => integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get targetDocumentId => integer().references(Documents, #id, onDelete: KeyAction.cascade)();

  // Link metadata
  TextColumn get linkType => text()(); // e.g., 'related', 'supersedes', 'claim', 'receipt'
  TextColumn get notes => text().nullable()();

  // Soft delete pattern
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Audit timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {sourceDocumentId, targetDocumentId, linkType}, // Prevent duplicate links
  ];
}

