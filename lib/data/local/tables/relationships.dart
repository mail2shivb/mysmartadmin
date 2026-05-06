import 'package:drift/drift.dart';

/// Relationships — typed links between any two user entities.
///
/// Implements the allowed relationship types from B6.2:
///   property ↔ policy_document      vehicle ↔ policy_document
///   account  ↔ statement_document   policy_document ↔ claim_document
///   property ↔ home_asset           subscription ↔ invoice_document
///
/// Entity kinds for both endpoints:
///   'document' | 'property' | 'vehicle' | 'account' | 'home_asset'
///
/// Relationship type IDs (canonical, must match allowed list):
///   'property_policy'  'vehicle_policy'      'account_statement'
///   'policy_claim'     'property_home_asset' 'subscription_invoice'
///
/// Integrity is enforced at the app layer on write; no FK to heterogeneous tables.
/// Directionality is intrinsic to [relationshipTypeId] — source/target are not symmetric.
@DataClassName('RelationshipEntity')
class Relationships extends Table {
  // ── Identity ──────────────────────────────────────────────────────────────

  IntColumn get id => integer().autoIncrement()();

  // ── Source endpoint ───────────────────────────────────────────────────────

  TextColumn get sourceEntityKind => text()();
  IntColumn get sourceEntityId => integer()();

  // ── Target endpoint ───────────────────────────────────────────────────────

  TextColumn get targetEntityKind => text()();
  IntColumn get targetEntityId => integer()();

  // ── Semantics ─────────────────────────────────────────────────────────────

  /// Canonical relationship type from the allowed list.
  TextColumn get relationshipTypeId => text()();

  /// Small optional JSON object for additional context
  /// (e.g. {"role": "primary_insured_vehicle"}).
  TextColumn get metadataJson => text().nullable()();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  DateTimeColumn get deletedAt => dateTime().nullable()();

  // ── Audit ─────────────────────────────────────────────────────────────────

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {
          sourceEntityKind,
          sourceEntityId,
          targetEntityKind,
          targetEntityId,
          relationshipTypeId,
        },
      ];
}
