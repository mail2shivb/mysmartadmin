import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/tables/document_links.dart';

/// Use case for linking documents together
///
/// Creates document_links entry and prevents duplicate links
class LinkDocumentUseCase {
  final AppDatabase _database;

  LinkDocumentUseCase(this._database);

  /// Create a link between two documents
  /// 
  /// Returns the ID of the newly created link
  Future<int> call({
    required int sourceDocumentId,
    required int targetDocumentId,
    required String linkType,
    String? notes,
  }) async {
    if (sourceDocumentId <= 0) {
      throw ArgumentError('Invalid source document ID');
    }

    if (targetDocumentId <= 0) {
      throw ArgumentError('Invalid target document ID');
    }

    if (sourceDocumentId == targetDocumentId) {
      throw ArgumentError('Cannot link a document to itself');
    }

    if (linkType.trim().isEmpty) {
      throw ArgumentError('Link type cannot be empty');
    }

    // Verify source document exists
    final sourceDocument = await _database.documentsDao.getDocumentById(sourceDocumentId);
    if (sourceDocument == null) {
      throw StateError('Source document with ID $sourceDocumentId not found');
    }

    // Verify target document exists
    final targetDocument = await _database.documentsDao.getDocumentById(targetDocumentId);
    if (targetDocument == null) {
      throw StateError('Target document with ID $targetDocumentId not found');
    }

    // Check if documents are already linked (in either direction)
    final alreadyLinked = await _database.documentLinksDao.areDocumentsLinked(
      sourceDocumentId,
      targetDocumentId,
    );

    if (alreadyLinked) {
      throw StateError('Documents are already linked');
    }

    // Create the link
    final linkId = await _database.documentLinksDao.createLink(
      DocumentLinksCompanion.insert(
        sourceDocumentId: sourceDocumentId,
        targetDocumentId: targetDocumentId,
        linkType: linkType,
        notes: Value(notes),
      ),
    );

    return linkId;
  }

  /// Get all links for a specific document
  Future<List<DocumentLinkEntity>> getLinksForDocument(int documentId) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    return await _database.documentLinksDao.getLinksForDocument(documentId);
  }

  /// Remove a link between documents
  Future<bool> removeLink(int linkId) async {
    if (linkId <= 0) {
      throw ArgumentError('Invalid link ID');
    }

    final link = await _database.documentLinksDao.getLinkById(linkId);
    if (link == null) {
      throw StateError('Link with ID $linkId not found');
    }

    final rowsAffected = await _database.documentLinksDao.softDeleteLink(linkId);
    return rowsAffected > 0;
  }
}

