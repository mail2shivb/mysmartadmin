import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';

class GetDocumentsUseCase {
  final AppDatabase _database;
  GetDocumentsUseCase(this._database);

  Future<List<DocumentEntity>> call({
    String? documentTypeId,
    String? categoryId,
    String? domainId,
    DateTime? expiringBefore,
    DateTime? expiringAfter,
  }) async {
    if (expiringAfter != null && expiringBefore != null) {
      DateRules.validateDateRange(expiringAfter, expiringBefore);
      return _database.documentsDao.getExpiringBetween(expiringAfter, expiringBefore);
    }
    if (documentTypeId != null && documentTypeId.trim().isNotEmpty) {
      return _database.documentsDao.getByDocumentType(documentTypeId);
    }
    if (categoryId != null && categoryId.trim().isNotEmpty) {
      return _database.documentsDao.getByCategory(categoryId);
    }
    if (domainId != null && domainId.trim().isNotEmpty) {
      return _database.documentsDao.getByDomain(domainId);
    }
    return _database.documentsDao.getAllDocuments();
  }

  Future<DocumentEntity?> getById(int documentId) async {
    if (documentId <= 0) throw ArgumentError('Invalid document ID');
    return _database.documentsDao.getDocumentById(documentId);
  }

  Future<List<DocumentEntity>> search(String query) async {
    if (query.trim().isEmpty) throw ArgumentError('Search query cannot be empty');
    return _database.documentsDao.searchDocuments(query);
  }

  Future<List<DocumentEntity>> fullTextSearch(String query) async {
    if (query.trim().isEmpty) throw ArgumentError('Search query cannot be empty');
    return _database.ftsSearch(query);
  }
}
