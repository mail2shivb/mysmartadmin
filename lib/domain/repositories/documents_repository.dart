import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for document operations.
///
/// Thin layer above [DocumentsDao] — delegates to existing DAO methods
/// and translates domain-level parameters to the B8 storage model.
class DocumentsRepository {
  final AppDatabase _database;

  DocumentsRepository(this._database);

  /// Add a new document (initially classification_pending).
  /// Classification is assigned separately via [DocumentsDao.classify].
  Future<int> addDocument({
    required String title,
    String? description,
    String? filePath,
    String? fileMime,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? issuer,
    String? referenceNumber,
    String source = 'manual',
  }) {
    return _database.documentsDao.insertDocument(
      DocumentsCompanion.insert(
        title: title,
        description: Value(description),
        filePath: Value(filePath),
        fileMime: Value(fileMime),
        issueDate: Value(issueDate),
        expiryDate: Value(expiryDate),
        issuer: Value(issuer),
        referenceNumber: Value(referenceNumber),
        source: Value(source),
      ),
    );
  }

  /// Stream all documents (excluding soft-deleted).
  Stream<List<DocumentEntity>> watchAllDocuments() =>
      _database.documentsDao.watchAllDocuments();

  /// Get a single document by ID.
  Future<DocumentEntity?> getDocumentById(int id) =>
      _database.documentsDao.getDocumentById(id);

  /// Soft-delete a document (reversible).
  Future<int> softDeleteDocument(int id) =>
      _database.documentsDao.softDeleteDocument(id);

  /// Restore a soft-deleted document.
  Future<int> restoreDocument(int id) =>
      _database.documentsDao.restoreDocument(id);

  /// Documents with [expiryDate] between [from] and [to].
  Future<List<DocumentEntity>> getDocumentsExpiringBetween(
    DateTime from,
    DateTime to,
  ) =>
      _database.documentsDao.getExpiringBetween(from, to);

  /// Full-text search across title, description, issuer, reference, OCR text.
  Future<List<DocumentEntity>> search(String query) =>
      _database.ftsSearch(query);
}
