import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/tables/documents.dart';
import '../../validation/expiry_rules.dart';
import '../../validation/date_rules.dart';

/// Use case for updating an existing document
///
/// Updates document metadata while preserving versioning handled by DAO
class UpdateDocumentUseCase {
  final AppDatabase _database;

  UpdateDocumentUseCase(this._database);

  /// Update document fields
  /// 
  /// Returns number of rows affected (1 if successful, 0 if document not found)
  Future<int> call({
    required int documentId,
    String? title,
    String? description,
    String? documentType,
    String? category,
    String? filePath,
    String? fileType,
    int? fileSizeBytes,
    String? extractedData,
    String? tags,
    DateTime? documentDate,
    DateTime? expiryDate,
    DateTime? reminderDate,
  }) async {
    if (documentId <= 0) {
      throw ArgumentError('Invalid document ID');
    }

    // Verify document exists
    final existingDocument = await _database.documentsDao.getDocumentById(documentId);
    if (existingDocument == null) {
      throw StateError('Document with ID $documentId not found');
    }

    // Validate file size if provided
    if (fileSizeBytes != null && fileSizeBytes < 0) {
      throw ArgumentError('File size cannot be negative');
    }

    // Validate date relationships if both provided
    final finalDocDate = documentDate ?? existingDocument.documentDate;
    final finalExpiry = expiryDate ?? existingDocument.expiryDate;
    if (finalDocDate != null && finalExpiry != null) {
      ExpiryRules.validateExpiryAfterIssue(finalDocDate, finalExpiry);
    }

    // Validate reminder date if provided
    if (reminderDate != null) {
      DateRules.validateFutureDate(reminderDate);
      DateRules.validateReasonableFutureDate(reminderDate);
    }

    // Validate expiry date if provided
    if (expiryDate != null) {
      DateRules.validateReasonableFutureDate(expiryDate);
    }

    // Build update companion with only provided fields
    final updates = DocumentsCompanion(
      title: title != null ? Value(title) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      documentType: documentType != null ? Value(documentType) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      filePath: filePath != null ? Value(filePath) : const Value.absent(),
      fileType: fileType != null ? Value(fileType) : const Value.absent(),
      fileSizeBytes: fileSizeBytes != null ? Value(fileSizeBytes) : const Value.absent(),
      extractedData: extractedData != null ? Value(extractedData) : const Value.absent(),
      tags: tags != null ? Value(tags) : const Value.absent(),
      documentDate: documentDate != null ? Value(documentDate) : const Value.absent(),
      expiryDate: expiryDate != null ? Value(expiryDate) : const Value.absent(),
      reminderDate: reminderDate != null ? Value(reminderDate) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final rowsAffected = await _database.documentsDao.updateDocumentFields(
      documentId,
      updates,
    );

    return rowsAffected;
  }
}

