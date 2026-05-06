import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/document_fields_meta.dart';

part 'document_fields_meta_dao.g.dart';

/// DAO for [DocumentFieldsMeta] — manages per-field OCR/user confirmation state.
///
/// Usage pattern:
///   1. After OCR: call [upsertConfirmations] with source='ocr', confirmed=false
///      for each auto-filled field.
///   2. After user edits a field: call [markFieldConfirmed] for that field.
///   3. Before an OCR re-run: call [isFieldConfirmed] to skip confirmed fields.
@DriftAccessor(tables: [DocumentFieldsMeta])
class DocumentFieldsMetaDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentFieldsMetaDaoMixin {
  DocumentFieldsMetaDao(AppDatabase db) : super(db);

  // ── READ ───────────────────────────────────────────────────────────────────

  Future<DocumentFieldsMetaEntity?> getForDocument(int documentId) =>
      (select(documentFieldsMeta)
            ..where((t) => t.documentId.equals(documentId)))
          .getSingleOrNull();

  Stream<DocumentFieldsMetaEntity?> watchForDocument(int documentId) =>
      (select(documentFieldsMeta)
            ..where((t) => t.documentId.equals(documentId)))
          .watchSingleOrNull();

  // ── WRITE ──────────────────────────────────────────────────────────────────

  /// Insert or replace the full confirmations JSON for a document.
  Future<void> upsertConfirmations(
      int documentId, String confirmationsJson) async {
    await into(documentFieldsMeta).insertOnConflictUpdate(
      DocumentFieldsMetaCompanion(
        documentId: Value(documentId),
        confirmationsJson: Value(confirmationsJson),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update only the [updatedAt] timestamp (e.g. after a partial edit).
  Future<int> touch(int documentId) =>
      (update(documentFieldsMeta)
            ..where((t) => t.documentId.equals(documentId)))
          .write(DocumentFieldsMetaCompanion(updatedAt: Value(DateTime.now())));

  // ── DELETE ─────────────────────────────────────────────────────────────────

  /// Hard-delete meta row. Called when the parent document is hard-deleted;
  /// cascade handles this automatically via the FK, but this is available
  /// for explicit cleanup.
  Future<int> deleteForDocument(int documentId) =>
      (delete(documentFieldsMeta)
            ..where((t) => t.documentId.equals(documentId)))
          .go();
}
