import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/document_links.dart';

part 'document_links_dao.g.dart';

/// Data Access Object for Document Links
/// 
/// Manages relationships between documents
@DriftAccessor(tables: [DocumentLinks])
class DocumentLinksDao extends DatabaseAccessor<AppDatabase> with _$DocumentLinksDaoMixin {
  DocumentLinksDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a link between two documents
  Future<int> createLink(DocumentLinksCompanion link) {
    return into(documentLinks).insert(link);
  }

  /// Create multiple links
  Future<void> createLinks(List<DocumentLinksCompanion> links) async {
    await batch((batch) {
      batch.insertAll(documentLinks, links);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a link by ID
  Future<DocumentLinkEntity?> getLinkById(int id) {
    return (select(documentLinks)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all links for a document (both as source and target)
  Future<List<DocumentLinkEntity>> getLinksForDocument(int documentId) {
    return (select(documentLinks)
          ..where((t) =>
              t.sourceDocumentId.equals(documentId) |
              t.targetDocumentId.equals(documentId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get outgoing links from a document
  Future<List<DocumentLinkEntity>> getOutgoingLinks(int documentId) {
    return (select(documentLinks)
          ..where((t) => t.sourceDocumentId.equals(documentId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get incoming links to a document
  Future<List<DocumentLinkEntity>> getIncomingLinks(int documentId) {
    return (select(documentLinks)
          ..where((t) => t.targetDocumentId.equals(documentId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get links by type
  Future<List<DocumentLinkEntity>> getLinksByType(String linkType) {
    return (select(documentLinks)
          ..where((t) => t.linkType.equals(linkType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Check if two documents are linked
  Future<bool> areDocumentsLinked(int sourceId, int targetId) async {
    final result = await (select(documentLinks)
          ..where((t) =>
              (t.sourceDocumentId.equals(sourceId) &
                  t.targetDocumentId.equals(targetId)) |
              (t.sourceDocumentId.equals(targetId) &
                  t.targetDocumentId.equals(sourceId)))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return result != null;
  }

  /// Stream links for a document
  Stream<List<DocumentLinkEntity>> watchLinksForDocument(int documentId) {
    return (select(documentLinks)
          ..where((t) =>
              t.sourceDocumentId.equals(documentId) |
              t.targetDocumentId.equals(documentId))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a link
  Future<bool> updateLink(DocumentLinkEntity link) {
    return update(documentLinks).replace(link);
  }

  /// Update link notes
  Future<int> updateLinkNotes(int id, String notes) {
    return (update(documentLinks)..where((t) => t.id.equals(id))).write(
      DocumentLinksCompanion(
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a link
  Future<int> softDeleteLink(int id) {
    return (update(documentLinks)..where((t) => t.id.equals(id))).write(
      DocumentLinksCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a link
  Future<int> hardDeleteLink(int id) {
    return (delete(documentLinks)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all links for a document
  Future<int> deleteLinksForDocument(int documentId) {
    return (delete(documentLinks)
          ..where((t) =>
              t.sourceDocumentId.equals(documentId) |
              t.targetDocumentId.equals(documentId)))
        .go();
  }

  /// Restore a soft deleted link
  Future<int> restoreLink(int id) {
    return (update(documentLinks)..where((t) => t.id.equals(id))).write(
      const DocumentLinksCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count links for a document
  Future<int> countLinksForDocument(int documentId) async {
    final query = selectOnly(documentLinks)
      ..addColumns([documentLinks.id.count()])
      ..where(
        documentLinks.sourceDocumentId.equals(documentId) |
        documentLinks.targetDocumentId.equals(documentId),
      )
      ..where(documentLinks.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(documentLinks.id.count()) ?? 0;
  }
}

