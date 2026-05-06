import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Table imports
import 'tables/documents.dart';
import 'tables/document_fields_meta.dart';
import 'tables/document_links.dart';
import 'tables/relationships.dart';
import 'tables/reminders.dart';
import 'tables/bills.dart';
import 'tables/subscriptions.dart';
import 'tables/policies.dart';
import 'tables/properties.dart';
import 'tables/vehicles.dart';
import 'tables/accounts.dart';
import 'tables/home_assets.dart';
import 'tables/compliance_records.dart';
import 'tables/service_records.dart';
import 'tables/claims.dart';
import 'tables/tasks.dart';

// DAO imports
import 'daos/documents_dao.dart';
import 'daos/document_fields_meta_dao.dart';
import 'daos/document_links_dao.dart';
import 'daos/relationships_dao.dart';
import 'daos/reminders_dao.dart';
import 'daos/bills_dao.dart';
import 'daos/subscriptions_dao.dart';
import 'daos/policies_dao.dart';
import 'daos/properties_dao.dart';
import 'daos/vehicles_dao.dart';
import 'daos/accounts_dao.dart';
import 'daos/home_assets_dao.dart';
import 'daos/compliance_records_dao.dart';
import 'daos/service_records_dao.dart';
import 'daos/claims_dao.dart';
import 'daos/tasks_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Documents,
    DocumentFieldsMeta,
    DocumentLinks,
    Relationships,
    Reminders,
    Bills,
    Subscriptions,
    Policies,
    Properties,
    Vehicles,
    Accounts,
    HomeAssets,
    ComplianceRecords,
    ServiceRecords,
    Claims,
    Tasks,
  ],
  daos: [
    DocumentsDao,
    DocumentFieldsMetaDao,
    DocumentLinksDao,
    RelationshipsDao,
    RemindersDao,
    BillsDao,
    SubscriptionsDao,
    PoliciesDao,
    PropertiesDao,
    VehiclesDao,
    AccountsDao,
    HomeAssetsDao,
    ComplianceRecordsDao,
    ServiceRecordsDao,
    ClaimsDao,
    TasksDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  factory AppDatabase() => _instance ??= AppDatabase._internal();

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createFts(this);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // v2 → v3: redesigned documents + reminders; added document_fields_meta,
        // relationships; removed document_id FKs from domain tables.
        if (from < 3) {
          // Recreate changed tables (dev-phase acceptable; data loss on documents
          // and reminders is expected during this pre-production stage).
          await m.deleteTable('documents');
          await m.deleteTable('reminders');
          await m.createTable(documents);
          await m.createTable(reminders);
          await m.createTable(documentFieldsMeta);
          await m.createTable(relationships);

          // Patch domain tables: drop the document_id column where it existed.
          // SQLite does not support DROP COLUMN below version 3.35; we
          // recreate the affected tables instead to stay broadly compatible.
          for (final tableName in ['properties', 'vehicles', 'accounts', 'home_assets']) {
            await _recreateWithoutDocumentId(m, tableName);
          }

          // Rebuild FTS table and triggers.
          await customStatement('DROP TABLE IF EXISTS documents_fts');
          await customStatement('DROP TRIGGER IF EXISTS documents_fts_ai');
          await customStatement('DROP TRIGGER IF EXISTS documents_fts_au');
          await customStatement('DROP TRIGGER IF EXISTS documents_fts_ad');
          await _createFts(this);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ── FTS5 setup ─────────────────────────────────────────────────────────────

  /// Creates the FTS5 virtual table and the three sync triggers.
  ///
  /// Uses a content table so the FTS index always mirrors [documents] without
  /// duplicating raw text storage. The triggers handle insert / update / delete.
  static Future<void> _createFts(AppDatabase db) async {
    // Content FTS5 table — rowid maps to documents.id.
    await db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts
      USING fts5(
        title, description, issuer, reference_number, ocr_text,
        content=documents,
        content_rowid=id,
        tokenize="porter unicode61"
      )
    ''');

    // INSERT trigger — fires after a new document row is added.
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS documents_fts_ai
      AFTER INSERT ON documents BEGIN
        INSERT INTO documents_fts(
          rowid, title, description, issuer, reference_number, ocr_text
        ) VALUES (
          new.id, new.title, new.description,
          new.issuer, new.reference_number, new.ocr_text
        );
      END
    ''');

    // UPDATE trigger — delete the old FTS row, insert the refreshed row.
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS documents_fts_au
      AFTER UPDATE ON documents BEGIN
        DELETE FROM documents_fts WHERE rowid = old.id;
        INSERT INTO documents_fts(
          rowid, title, description, issuer, reference_number, ocr_text
        ) VALUES (
          new.id, new.title, new.description,
          new.issuer, new.reference_number, new.ocr_text
        );
      END
    ''');

    // DELETE trigger — remove the FTS row when the document is hard-deleted.
    // Soft-deleted documents remain indexed (they may be restored).
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS documents_fts_ad
      AFTER DELETE ON documents BEGIN
        DELETE FROM documents_fts WHERE rowid = old.id;
      END
    ''');
  }

  // ── Migration helper ───────────────────────────────────────────────────────

  /// Drops and recreates a domain table by name so any legacy document_id
  /// column is removed. Only called during the v2→v3 migration path.
  Future<void> _recreateWithoutDocumentId(
      Migrator m, String tableName) async {
    // For SQLite compatibility we use ALTER TABLE rename + recreate pattern.
    // The affected tables are simple enough that data loss is acceptable
    // at this pre-production stage. In a production release this would be
    // a proper data-preserving migration.
    switch (tableName) {
      case 'properties':
        await m.deleteTable('properties');
        await m.createTable(properties);
      case 'vehicles':
        await m.deleteTable('vehicles');
        await m.createTable(vehicles);
      case 'accounts':
        await m.deleteTable('accounts');
        await m.createTable(accounts);
      case 'home_assets':
        await m.deleteTable('home_assets');
        await m.createTable(homeAssets);
    }
  }

  // ── Maintenance ────────────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    await transaction(() async {
      await batch((b) {
        b.deleteAll(documentFieldsMeta);
        b.deleteAll(relationships);
        b.deleteAll(documentLinks);
        b.deleteAll(reminders);
        b.deleteAll(documents);
        b.deleteAll(policies);
        b.deleteAll(bills);
        b.deleteAll(subscriptions);
        b.deleteAll(accounts);
        b.deleteAll(properties);
        b.deleteAll(vehicles);
        b.deleteAll(homeAssets);
        b.deleteAll(complianceRecords);
        b.deleteAll(serviceRecords);
        b.deleteAll(claims);
        b.deleteAll(tasks);
      });
    });
  }

  Future<void> hardReset() async {
    await transaction(() async {
      await customStatement('PRAGMA foreign_keys = OFF');
      await clearAllData();
      await customStatement('PRAGMA foreign_keys = ON');
    });
  }

  // ── FTS search helper ──────────────────────────────────────────────────────

  /// Sanitize a raw user query into a safe FTS5 MATCH expression.
  ///
  /// Strategy: split on whitespace, wrap every token in double-quotes
  /// (escaping any embedded double-quote as ""), and append a prefix
  /// wildcard '*' to the last token so partial words match.
  ///
  /// This prevents user input like `OR`, `NOT`, `"`, or unmatched parens
  /// from causing FTS5 parse errors or injecting unintended query operators.
  static String _sanitizeFtsQuery(String raw) {
    final tokens = raw.trim().split(RegExp(r'\s+'));
    final safe = tokens
        .where((t) => t.isNotEmpty)
        // Escape embedded double-quotes, then wrap token in double-quotes.
        .map((t) => '"${t.replaceAll('"', '""')}"')
        .toList();
    if (safe.isEmpty) return '""';
    // Append prefix wildcard to the last token for incremental search.
    safe[safe.length - 1] = '${safe.last}*';
    return safe.join(' ');
  }

  /// Full-text search against the documents_fts index.
  /// Returns matching [DocumentEntity] rows, excluding soft-deleted ones.
  ///
  /// Returns an empty list immediately if [query] is blank — an FTS5 MATCH
  /// against an empty token is an error in some SQLite builds and semantically
  /// meaningless in all builds.
  Future<List<DocumentEntity>> ftsSearch(String query) async {
    if (query.trim().isEmpty) return const [];
    final ftsQuery = _sanitizeFtsQuery(query);
    final results = await customSelect(
      '''
      SELECT d.*
      FROM documents d
      JOIN documents_fts fts ON fts.rowid = d.id
      WHERE documents_fts MATCH ?
        AND d.deleted_at IS NULL
      ORDER BY rank
      ''',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {documents},
    ).get();
    return results.map((row) => documents.map(row.data)).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mysmartadmin.sqlite'));
    return NativeDatabase(file);
  });
}
