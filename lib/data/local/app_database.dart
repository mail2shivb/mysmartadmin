import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Table imports
import 'tables/documents.dart';
import 'tables/document_links.dart';
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
import 'daos/document_links_dao.dart';
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

/// Main application database using Drift
/// 
/// Features:
/// - SQLite local-only storage
/// - Offline-first architecture
/// - Soft delete pattern on all entities
/// - Versioning support where specified
/// - No backend dependencies
@DriftDatabase(
  tables: [
    Documents,
    DocumentLinks,
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
    DocumentLinksDao,
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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will go here
        // Example:
        // if (from < 2) {
        //   await m.addColumn(documents, documents.newColumn);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        
        if (details.wasCreated) {
          // Database was just created - initial setup if needed
          // No seed data per requirements
        }
      },
    );
  }
}

/// Opens the database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mysmartadmin.sqlite'));
    return NativeDatabase(file);
  });
}

