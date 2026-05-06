import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/documents.dart';

part 'documents_dao.g.dart';

@DriftAccessor(tables: [Documents])
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(AppDatabase db) : super(db);

  // ── CREATE ─────────────────────────────────────────────────────────────────

  Future<int> insertDocument(DocumentsCompanion document) =>
      into(documents).insert(document);

  Future<void> insertDocuments(List<DocumentsCompanion> docs) async {
    await batch((b) => b.insertAll(documents, docs));
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  Future<DocumentEntity?> getDocumentById(int id) =>
      (select(documents)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.deletedAt.isNull()))
          .getSingleOrNull();

  Future<List<DocumentEntity>> getAllDocuments() =>
      (select(documents)..where((t) => t.deletedAt.isNull())).get();

  // ── Classification-based queries ──────────────────────────────────────────

  Future<List<DocumentEntity>> getByDomain(String domainId) =>
      (select(documents)
            ..where((t) => t.domainId.equals(domainId))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  Future<List<DocumentEntity>> getByCategory(String categoryId) =>
      (select(documents)
            ..where((t) => t.categoryId.equals(categoryId))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  Future<List<DocumentEntity>> getByDocumentType(String documentTypeId) =>
      (select(documents)
            ..where((t) => t.documentTypeId.equals(documentTypeId))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  Future<List<DocumentEntity>> getPendingClassification() =>
      (select(documents)
            ..where((t) =>
                t.classificationState.equals('classification_pending'))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  Stream<List<DocumentEntity>> watchPendingClassification() =>
      (select(documents)
            ..where((t) =>
                t.classificationState.equals('classification_pending'))
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  // ── Date-driven queries (for dashboard / reminders) ───────────────────────

  Future<List<DocumentEntity>> getExpiringBetween(
      DateTime start, DateTime end) =>
      (select(documents)
            ..where((t) => t.expiryDate.isBetweenValues(start, end))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.expiryDate)]))
          .get();

  Future<List<DocumentEntity>> getRenewalsBetween(
      DateTime start, DateTime end) =>
      (select(documents)
            ..where((t) => t.renewalDate.isBetweenValues(start, end))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
          .get();

  // ── Search (title / description — FTS handled separately via customSelect) ─

  Future<List<DocumentEntity>> searchDocuments(String query) {
    final pattern = '%$query%';
    return (select(documents)
          ..where((t) =>
              t.title.like(pattern) |
              t.description.like(pattern) |
              t.issuer.like(pattern) |
              t.referenceNumber.like(pattern))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  // ── Versioning ────────────────────────────────────────────────────────────

  Future<List<DocumentEntity>> getVersionChain(int documentId) =>
      (select(documents)
            ..where((t) =>
                t.id.equals(documentId) |
                t.previousVersionId.equals(documentId))
            ..orderBy([(t) => OrderingTerm.desc(t.version)]))
          .get();

  // ── Watch ─────────────────────────────────────────────────────────────────

  Stream<List<DocumentEntity>> watchAllDocuments() =>
      (select(documents)..where((t) => t.deletedAt.isNull())).watch();

  Stream<List<DocumentEntity>> watchByDomain(String domainId) =>
      (select(documents)
            ..where((t) => t.domainId.equals(domainId))
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  Stream<List<DocumentEntity>> watchByCategory(String categoryId) =>
      (select(documents)
            ..where((t) => t.categoryId.equals(categoryId))
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  Future<bool> updateDocument(DocumentEntity doc) =>
      update(documents).replace(doc);

  Future<int> updateDocumentFields(int id, DocumentsCompanion updates) =>
      (update(documents)..where((t) => t.id.equals(id))).write(updates);

  /// Classify or reclassify a document.
  ///
  /// Guards:
  /// - Taxonomy ID fields must be non-empty strings (they carry no FK so
  ///   we validate at the call site).
  /// - [allowReclassify] must be `true` to overwrite an already-classified
  ///   document; this prevents silent overwrites triggered by OCR re-runs or
  ///   duplicate API calls.
  /// - Throws [StateError] if the document does not exist or is soft-deleted.
  Future<int> classify({
    required int id,
    required String documentTypeId,
    required String categoryId,
    required String domainId,
    required int taxonomyVersion,
    bool allowReclassify = false,
  }) async {
    // Validate taxonomy ID fields — stored as plain TEXT with no FK constraint.
    if (documentTypeId.trim().isEmpty) {
      throw ArgumentError('documentTypeId cannot be empty');
    }
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('categoryId cannot be empty');
    }
    if (domainId.trim().isEmpty) {
      throw ArgumentError('domainId cannot be empty');
    }
    if (taxonomyVersion <= 0) {
      throw ArgumentError('taxonomyVersion must be a positive integer');
    }

    // Load the live document so we can inspect its current classification state.
    final doc = await getDocumentById(id);
    if (doc == null) {
      throw StateError('Document $id not found or has been deleted');
    }

    // Guard against silent reclassification: the caller must opt-in explicitly.
    if (doc.classificationState == 'classified' && !allowReclassify) {
      throw StateError(
        'Document $id is already classified. '
        'Pass allowReclassify: true to overwrite.',
      );
    }

    final rows = await (update(documents)..where((t) => t.id.equals(id))).write(
      DocumentsCompanion(
        documentTypeId: Value(documentTypeId),
        categoryId: Value(categoryId),
        domainId: Value(domainId),
        taxonomyVersion: Value(taxonomyVersion),
        classificationState: const Value('classified'),
        updatedAt: Value(DateTime.now()),
      ),
    );
    // rows == 0 should not happen after the getDocumentById guard above,
    // but guard defensively in case of a race between fetch and write.
    if (rows == 0) {
      throw StateError('Document $id could not be classified (concurrent modification?)');
    }
    return rows;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<int> softDeleteDocument(int id) =>
      (update(documents)..where((t) => t.id.equals(id))).write(
        DocumentsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> hardDeleteDocument(int id) =>
      (delete(documents)..where((t) => t.id.equals(id))).go();

  Future<int> restoreDocument(int id) =>
      (update(documents)..where((t) => t.id.equals(id))).write(
        const DocumentsCompanion(deletedAt: Value(null)),
      );

  Future<List<DocumentEntity>> getSoftDeletedDocuments() =>
      (select(documents)..where((t) => t.deletedAt.isNotNull())).get();

  // ── STATISTICS ─────────────────────────────────────────────────────────────

  Future<int> countAll() async {
    final q = selectOnly(documents)
      ..addColumns([documents.id.count()])
      ..where(documents.deletedAt.isNull());
    final r = await q.getSingle();
    return r.read(documents.id.count()) ?? 0;
  }

  Future<int> countByDomain(String domainId) async {
    final q = selectOnly(documents)
      ..addColumns([documents.id.count()])
      ..where(documents.domainId.equals(domainId))
      ..where(documents.deletedAt.isNull());
    final r = await q.getSingle();
    return r.read(documents.id.count()) ?? 0;
  }

  Future<int> countPendingClassification() async {
    final q = selectOnly(documents)
      ..addColumns([documents.id.count()])
      ..where(documents.classificationState.equals('classification_pending'))
      ..where(documents.deletedAt.isNull());
    final r = await q.getSingle();
    return r.read(documents.id.count()) ?? 0;
  }
}
