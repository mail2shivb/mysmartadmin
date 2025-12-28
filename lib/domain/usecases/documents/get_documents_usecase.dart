import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';

/// Use case for retrieving documents
///
/// Fetches all non-deleted documents with optional filtering
class GetDocumentsUseCase {
  final AppDatabase _database;

  GetDocumentsUseCase(this._database);

  /// Get documents with optional filters
  /// 
  /// Returns list of documents matching the criteria
  Future<List<DocumentEntity>> call({
    String? documentType,
    String? category,
    DateTime? expiringBefore,
    DateTime? expiringAfter,
  }) async {
    // If filtering by expiry date range
    if (expiringAfter != null && expiringBefore != null) {
      DateRules.validateDateRange(expiringAfter, expiringBefore);
      return await _database.documentsDao.getDocumentsExpiringBetween(
        expiringAfter,
        expiringBefore,
      );
    }

    // If filtering by document type
    if (documentType != null && documentType.trim().isNotEmpty) {
      return await _database.documentsDao.getDocumentsByType(documentType);
    }

    // If filtering by category
    if (category != null && category.trim().isNotEmpty) {
      return await _database.documentsDao.getDocumentsByCategory(category);
    }

    // No filters - return all documents
    return await _database.documentsDao.getAllDocuments();
  }

  /// Get a single document by ID
  Future<DocumentEntity?> getById(int documentId) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    return await _database.documentsDao.getDocumentById(documentId);
  }

  /// Search documents by query string
  Future<List<DocumentEntity>> search(String query) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }

    return await _database.documentsDao.searchDocuments(query);
  }
}

