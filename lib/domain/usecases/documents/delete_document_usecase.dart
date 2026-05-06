import '../../../data/local/app_database.dart';

/// Soft-deletes a document and cascades the deletion to its associated data.
///
/// Cascade order (all within one transaction):
///   1. Dismiss any pending/due reminders sourced from this document.
///   2. Soft-delete all DocumentLinks for this document.
///   3. Soft-delete the document itself.
class DeleteDocumentUseCase {
  final AppDatabase _database;

  DeleteDocumentUseCase(this._database);

  /// Returns true if the document was soft-deleted successfully.
  Future<bool> call(int documentId) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    final existing = await _database.documentsDao.getDocumentById(documentId);
    if (existing == null) {
      throw StateError('Document $documentId not found');
    }

    return _database.transaction(() async {
      // 1. Dismiss active reminders so they don't surface after deletion.
      //    Uses 'dismissed' (not 'cancelled') because the user is removing the
      //    document record — it existed and the reminder was valid; it's now moot.
      await _database.remindersDao.dismissForSource('document', documentId);

      // 2. Soft-delete DocumentLinks (legacy linkage table).
      final links =
          await _database.documentLinksDao.getLinksForDocument(documentId);
      for (final link in links) {
        await _database.documentLinksDao.softDeleteLink(link.id);
      }

      // 3. Soft-delete the document itself.
      final rowsAffected =
          await _database.documentsDao.softDeleteDocument(documentId);

      return rowsAffected > 0;
    });
  }
}

