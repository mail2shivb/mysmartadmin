import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';
import '../../validation/expiry_rules.dart';
import '../../validation/date_rules.dart';

class UpdateDocumentUseCase {
  final AppDatabase _database;
  UpdateDocumentUseCase(this._database);

  Future<int> call({
    required int documentId,
    String? title,
    String? description,
    String? issuer,
    String? referenceNumber,
    String? filePath,
    String? fileMime,
    int? fileSizeBytes,
    String? extraFieldsJson,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    if (documentId <= 0) throw ArgumentError('Invalid document ID');

    final existing = await _database.documentsDao.getDocumentById(documentId);
    if (existing == null) throw StateError('Document $documentId not found');

    if (fileSizeBytes != null && fileSizeBytes < 0) {
      throw ArgumentError('File size cannot be negative');
    }
    if (extraFieldsJson != null) {
      _validateJsonObject(extraFieldsJson);
    }

    final finalIssue = issueDate ?? existing.issueDate;
    final finalExpiry = expiryDate ?? existing.expiryDate;
    if (finalIssue != null && finalExpiry != null) {
      ExpiryRules.validateExpiryAfterIssue(finalIssue, finalExpiry);
    }
    if (expiryDate != null) {
      DateRules.validateReasonableFutureDate(expiryDate);
    }

    // Merge incoming Zone-B fields with the stored JSON rather than replacing it
    // entirely. This preserves keys that callers do not mention in this update.
    final mergedJson = extraFieldsJson != null
        ? _mergeJsonObjects(existing.extraFieldsJson, extraFieldsJson)
        : null;

    final updates = DocumentsCompanion(
      title: title != null ? Value(title) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      issuer: issuer != null ? Value(issuer) : const Value.absent(),
      referenceNumber:
          referenceNumber != null ? Value(referenceNumber) : const Value.absent(),
      filePath: filePath != null ? Value(filePath) : const Value.absent(),
      fileMime: fileMime != null ? Value(fileMime) : const Value.absent(),
      fileSizeBytes:
          fileSizeBytes != null ? Value(fileSizeBytes) : const Value.absent(),
      extraFieldsJson:
          mergedJson != null ? Value(mergedJson) : const Value.absent(),
      issueDate: issueDate != null ? Value(issueDate) : const Value.absent(),
      expiryDate: expiryDate != null ? Value(expiryDate) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return _database.documentsDao.updateDocumentFields(documentId, updates);
  }

  /// Validate [json] is a well-formed JSON object (map at the top level).
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

  /// Shallow-merge two JSON objects: [incoming] keys override [existing] keys.
  ///
  /// If [existing] is null or empty, [incoming] is returned as-is.
  /// Both strings must already be validated as JSON objects before calling this.
  static String _mergeJsonObjects(String? existing, String incoming) {
    if (existing == null || existing.isEmpty) return incoming;
    final existingMap =
        Map<String, dynamic>.from(jsonDecode(existing) as Map);
    final incomingMap =
        Map<String, dynamic>.from(jsonDecode(incoming) as Map);
    // Incoming keys win; existing keys not mentioned in incoming are preserved.
    return jsonEncode({...existingMap, ...incomingMap});
  }
}
