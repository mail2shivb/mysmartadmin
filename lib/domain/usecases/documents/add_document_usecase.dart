import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/tables/documents.dart';
import '../../validation/entity_validators.dart';

/// Use case for adding a new document
///
/// Inserts document via DocumentsDao and returns the inserted document ID
class AddDocumentUseCase {
  final AppDatabase _database;

  AddDocumentUseCase(this._database);

  /// Add a new document
  /// 
  /// Returns the ID of the newly created document
  Future<int> call({
    required String title,
    required String documentType,
    required String category,
    String? description,
    String? filePath,
    String? fileType,
    int? fileSizeBytes,
    String? extractedData,
    String? tags,
    DateTime? documentDate,
    DateTime? expiryDate,
    DateTime? reminderDate,
  }) async {
    // Use centralized entity validator
    EntityValidators.validateDocument(
      title: title,
      documentType: documentType,
      category: category,
      documentDate: documentDate,
      expiryDate: expiryDate,
      reminderDate: reminderDate,
      fileSizeBytes: fileSizeBytes,
    );

    final documentId = await _database.documentsDao.insertDocument(
      DocumentsCompanion.insert(
        title: title,
        documentType: documentType,
        category: category,
        description: Value(description),
        filePath: Value(filePath),
        fileType: Value(fileType),
        fileSizeBytes: Value(fileSizeBytes),
        extractedData: Value(extractedData),
        tags: Value(tags),
        documentDate: Value(documentDate),
        expiryDate: Value(expiryDate),
        reminderDate: Value(reminderDate),
      ),
    );

    return documentId;
  }
}

