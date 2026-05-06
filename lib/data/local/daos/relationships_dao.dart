import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/relationships.dart';

part 'relationships_dao.g.dart';

@DriftAccessor(tables: [Relationships])
class RelationshipsDao extends DatabaseAccessor<AppDatabase>
    with _$RelationshipsDaoMixin {
  RelationshipsDao(AppDatabase db) : super(db);

  // ── CREATE ─────────────────────────────────────────────────────────────────

  Future<int> insertRelationship(RelationshipsCompanion rel) =>
      into(relationships).insert(rel);

  /// Insert a relationship identified by the canonical 5-tuple, or restore it
  /// if a soft-deleted row for the same 5-tuple already exists.
  ///
  /// Why this is needed: the UNIQUE constraint covers the 5-tuple regardless of
  /// [deletedAt], so a plain INSERT would fail with a constraint error if the
  /// row was previously soft-deleted.  This method handles the three cases:
  ///   • No row exists   → INSERT, return new ID.
  ///   • Live row exists → no-op, return existing ID (idempotent).
  ///   • Soft-deleted row exists → clear [deletedAt] and return its ID.
  Future<int> insertOrRestoreRelationship({
    required String sourceEntityKind,
    required int sourceEntityId,
    required String targetEntityKind,
    required int targetEntityId,
    required String relationshipTypeId,
    String? metadataJson,
  }) async {
    // Look for any existing row (live or soft-deleted) with the same 5-tuple.
    final existing = await (select(relationships)
          ..where((t) =>
              t.sourceEntityKind.equals(sourceEntityKind) &
              t.sourceEntityId.equals(sourceEntityId) &
              t.targetEntityKind.equals(targetEntityKind) &
              t.targetEntityId.equals(targetEntityId) &
              t.relationshipTypeId.equals(relationshipTypeId)))
        .getSingleOrNull();

    if (existing == null) {
      // No prior row — standard insert.
      return into(relationships).insert(
        RelationshipsCompanion.insert(
          sourceEntityKind: sourceEntityKind,
          sourceEntityId: sourceEntityId,
          targetEntityKind: targetEntityKind,
          targetEntityId: targetEntityId,
          relationshipTypeId: relationshipTypeId,
          metadataJson: Value(metadataJson),
        ),
      );
    }

    if (existing.deletedAt == null) {
      // Already live — nothing to do.
      return existing.id;
    }

    // Soft-deleted row exists — restore it.
    await (update(relationships)..where((t) => t.id.equals(existing.id))).write(
      RelationshipsCompanion(
        deletedAt: const Value(null), // clear soft-delete flag
        metadataJson: Value(metadataJson ?? existing.metadataJson),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return existing.id;
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  Future<RelationshipEntity?> getById(int id) =>
      (select(relationships)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.deletedAt.isNull()))
          .getSingleOrNull();

  /// All active relationships where [kind]:[id] is the source endpoint.
  Future<List<RelationshipEntity>> getForSource(
      String kind, int entityId) =>
      (select(relationships)
            ..where((t) =>
                t.sourceEntityKind.equals(kind) &
                t.sourceEntityId.equals(entityId))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  /// All active relationships where [kind]:[id] is the target endpoint.
  Future<List<RelationshipEntity>> getForTarget(
      String kind, int entityId) =>
      (select(relationships)
            ..where((t) =>
                t.targetEntityKind.equals(kind) &
                t.targetEntityId.equals(entityId))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  /// All active relationships of a specific type originating from a source.
  Future<List<RelationshipEntity>> getForSourceByType(
      String kind, int entityId, String relationshipTypeId) =>
      (select(relationships)
            ..where((t) =>
                t.sourceEntityKind.equals(kind) &
                t.sourceEntityId.equals(entityId) &
                t.relationshipTypeId.equals(relationshipTypeId))
            ..where((t) => t.deletedAt.isNull()))
          .get();

  /// Stream all relationships for a source entity (live updates).
  Stream<List<RelationshipEntity>> watchForSource(
      String kind, int entityId) =>
      (select(relationships)
            ..where((t) =>
                t.sourceEntityKind.equals(kind) &
                t.sourceEntityId.equals(entityId))
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  Future<bool> updateRelationship(RelationshipEntity rel) =>
      update(relationships).replace(rel);

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<int> softDelete(int id) =>
      (update(relationships)..where((t) => t.id.equals(id))).write(
        RelationshipsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Soft-delete all relationships for a given endpoint (either source or target).
  /// Called when a record is soft-deleted to cascade the relationship state.
  Future<void> softDeleteForEntity(String kind, int entityId) async {
    final now = DateTime.now();
    await (update(relationships)
          ..where((t) =>
              (t.sourceEntityKind.equals(kind) &
                  t.sourceEntityId.equals(entityId)) |
              (t.targetEntityKind.equals(kind) &
                  t.targetEntityId.equals(entityId)))
          ..where((t) => t.deletedAt.isNull()))
        .write(RelationshipsCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<int> hardDelete(int id) =>
      (delete(relationships)..where((t) => t.id.equals(id))).go();
}
