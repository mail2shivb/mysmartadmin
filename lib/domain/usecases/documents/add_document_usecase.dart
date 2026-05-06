import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';

/// Inserts a new document (initially classification_pending).
/// Classification is applied separately via [DocumentsDao.classify].
class AddDocumentUseCase {
  final AppDatabase _database;
  AddDocumentUseCase(this._database);

  Future<int> call({
    required String title,
    String? description,
    String? filePath,
    String? fileMime,
    int? fileSizeBytes,
    String? issuer,
    String? referenceNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? extraFieldsJson,
    String source = 'manual',
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Document title cannot be empty');
    }
    if (fileSizeBytes != null && fileSizeBytes < 0) {
      throw ArgumentError('File size cannot be negative');
    }
    if (extraFieldsJson != null) {
      _validateJsonObject(extraFieldsJson);
    }

    return _database.documentsDao.insertDocument(
      DocumentsCompanion.insert(
        title: title,
        description: Value(description),
        filePath: Value(filePath),
        fileMime: Value(fileMime),
        fileSizeBytes: Value(fileSizeBytes),
        issuer: Value(issuer),
        referenceNumber: Value(referenceNumber),
        issueDate: Value(issueDate),
        expiryDate: Value(expiryDate),
        extraFieldsJson: Value(extraFieldsJson),
        source: Value(source),
      ),
    );
  }

  /// Ensure [json] is a valid JSON object (map at the top level).
  /// Throws [ArgumentError] on invalid JSON or non-object root types.
  static void _validateJsonObject(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) {
        throw ArgumentError(
            'extraFieldsJson must be a JSON object (got ${decoded.runtimeType})');
      }
    } on FormatException catch (e) {
      throw ArgumentError('extraFieldsJson is not valid JSON: $e');
    }
  }
}
