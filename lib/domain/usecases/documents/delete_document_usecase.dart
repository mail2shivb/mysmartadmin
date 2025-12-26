import '../../../data/local/app_database.dart';

/// Use case for deleting a document
///
/// Performs soft delete on document and removes all associated document links
class DeleteDocumentUseCase {
  final AppDatabase _database;

  DeleteDocumentUseCase(this._database);

  /// Soft delete a document and its links
  /// 
  /// Returns true if deletion was successful
  Future<bool> call(int documentId) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    // Verify document exists
    final existingDocument = await _database.documentsDao.getDocumentById(documentId);
    if (existingDocument == null) {
      throw StateError('Document with ID $documentId not found');
    }

    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // Get all links for this document
      final links = await _database.documentLinksDao.getLinksForDocument(documentId);

      // Soft delete all associated links
      for (final link in links) {
        await _database.documentLinksDao.softDeleteLink(link.id);
      }

      // Soft delete the document
      final rowsAffected = await _database.documentsDao.softDeleteDocument(documentId);

      return rowsAffected > 0;
    });
  }
}

