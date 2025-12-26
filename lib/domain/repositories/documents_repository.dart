import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for document operations
/// 
/// Thin layer above documentsDao - delegates to existing DAO methods
class DocumentsRepository {
  final AppDatabase _database;

  DocumentsRepository(this._database);

  /// Add a new document
  /// Returns the inserted document ID
  Future<int> addDocument({
    required String name,
    required String documentType,
    required String category,
    required String filePath,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
  }) {
    return _database.documentsDao.insertDocument(
      DocumentsCompanion.insert(
        title: name,
        category: category,
        documentType: documentType,
        filePath: Value(filePath),
        documentDate: Value(issueDate),
        expiryDate: Value(expiryDate),
        description: Value(notes),
      ),
    );
  }

  /// Stream all documents (excluding soft deleted)
  Stream<List<DocumentEntity>> watchAllDocuments() {
    return _database.documentsDao.watchAllDocuments();
  }

  /// Get a single document by ID
  Future<DocumentEntity?> getDocumentById(int id) {
    return _database.documentsDao.getDocumentById(id);
  }

  /// Soft delete a document (can be restored later)
  Future<int> softDeleteDocument(int id) {
    return _database.documentsDao.softDeleteDocument(id);
  }

  /// Restore a previously soft-deleted document
  Future<int> restoreDocument(int id) {
    return _database.documentsDao.restoreDocument(id);
  }

  /// Get documents expiring within a date range
  Future<List<DocumentEntity>> getDocumentsExpiringBetween(
    DateTime from,
    DateTime to,
  ) {
    return _database.documentsDao.getDocumentsExpiringBetween(from, to);
  }
}
