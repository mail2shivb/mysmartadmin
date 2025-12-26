import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/documents.dart';

part 'documents_dao.g.dart';

/// Data Access Object for Documents
/// 
/// Provides CRUD operations with soft delete support
@DriftAccessor(tables: [Documents])
class DocumentsDao extends DatabaseAccessor<AppDatabase> with _$DocumentsDaoMixin {
  DocumentsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Insert a new document
  Future<int> insertDocument(DocumentsCompanion document) {
    return into(documents).insert(document);
  }

  /// Insert multiple documents
  Future<void> insertDocuments(List<DocumentsCompanion> documentList) async {
    await batch((batch) {
      batch.insertAll(documents, documentList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a single document by ID (excluding soft deleted)
  Future<DocumentEntity?> getDocumentById(int id) {
    return (select(documents)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all documents (excluding soft deleted)
  Future<List<DocumentEntity>> getAllDocuments() {
    return (select(documents)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Get documents by category
  Future<List<DocumentEntity>> getDocumentsByCategory(String category) {
    return (select(documents)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get documents by type
  Future<List<DocumentEntity>> getDocumentsByType(String documentType) {
    return (select(documents)
          ..where((t) => t.documentType.equals(documentType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get documents expiring within a date range
  Future<List<DocumentEntity>> getDocumentsExpiringBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(documents)
          ..where((t) => t.expiryDate.isBetweenValues(start, end))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.expiryDate)]))
        .get();
  }

  /// Search documents by title or description
  Future<List<DocumentEntity>> searchDocuments(String query) {
    final searchPattern = '%$query%';
    return (select(documents)
          ..where((t) =>
              t.title.like(searchPattern) |
              t.description.like(searchPattern))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get document versions (for a specific document chain)
  Future<List<DocumentEntity>> getDocumentVersions(int documentId) {
    return (select(documents)
          ..where((t) =>
              t.id.equals(documentId) |
              t.previousVersionId.equals(documentId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Stream all documents (for real-time updates)
  Stream<List<DocumentEntity>> watchAllDocuments() {
    return (select(documents)..where((t) => t.deletedAt.isNull())).watch();
  }

  /// Stream documents by category
  Stream<List<DocumentEntity>> watchDocumentsByCategory(String category) {
    return (select(documents)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a document
  Future<bool> updateDocument(DocumentEntity document) {
    return update(documents).replace(document);
  }

  /// Update specific fields of a document
  Future<int> updateDocumentFields(int id, DocumentsCompanion updates) {
    return (update(documents)..where((t) => t.id.equals(id))).write(updates);
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a document
  Future<int> softDeleteDocument(int id) {
    return (update(documents)..where((t) => t.id.equals(id))).write(
      DocumentsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a document (permanent)
  Future<int> hardDeleteDocument(int id) {
    return (delete(documents)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted document
  Future<int> restoreDocument(int id) {
    return (update(documents)..where((t) => t.id.equals(id))).write(
      const DocumentsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  /// Get all soft deleted documents
  Future<List<DocumentEntity>> getSoftDeletedDocuments() {
    return (select(documents)..where((t) => t.deletedAt.isNotNull())).get();
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count documents by category
  Future<int> countDocumentsByCategory(String category) async {
    final query = selectOnly(documents)
      ..addColumns([documents.id.count()])
      ..where(documents.category.equals(category))
      ..where(documents.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(documents.id.count()) ?? 0;
  }

  /// Count all documents
  Future<int> countAllDocuments() async {
    final query = selectOnly(documents)
      ..addColumns([documents.id.count()])
      ..where(documents.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(documents.id.count()) ?? 0;
  }
}

