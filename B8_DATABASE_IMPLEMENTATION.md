# B8: Local Database Implementation

## Status: ✅ COMPLETE

**Generated:** 2025-12-26  
**Database Version:** v1 (Initial Migration)

---

## Objective

Implement a production-grade SQLite local database using Drift (Flutter) with offline-first architecture, soft delete patterns, and versioning support.

---

## Architecture Overview

### Technology Stack
- **Drift**: Type-safe SQLite wrapper for Flutter/Dart
- **SQLite**: Local-only storage (no backend)
- **Native Database**: Platform-specific SQLite implementation
- **Path Provider**: Cross-platform file system access

### Design Principles
✅ Offline-first (no network dependencies)  
✅ Privacy-first (all data local only)  
✅ Soft delete pattern (recoverability)  
✅ Versioning support (audit trail)  
✅ Foreign key constraints enabled  
✅ Type-safe queries  
✅ Reactive streams (real-time updates)  

---

## Database Schema (v1)

### Tables Implemented

#### 1. **Documents** (Core Entity)
Primary table for storing all document metadata across all domains.

**Columns:**
- `id` - INTEGER PRIMARY KEY AUTOINCREMENT
- `title` - TEXT NOT NULL (1-255 chars)
- `description` - TEXT
- `document_type` - TEXT (e.g., 'passport', 'bill', 'policy')
- `category` - TEXT (domain: property, vehicle, finance, etc.)
- `file_path` - TEXT (local file path)
- `file_type` - TEXT (mime type)
- `file_size_bytes` - INTEGER
- `extracted_data` - TEXT (JSON for OCR data)
- `tags` - TEXT (comma-separated or JSON)
- `document_date` - DATETIME
- `expiry_date` - DATETIME
- `reminder_date` - DATETIME
- `deleted_at` - DATETIME (soft delete)
- `version` - INTEGER (default: 1)
- `previous_version_id` - INTEGER FK → documents(id)
- `created_at` - DATETIME (auto)
- `updated_at` - DATETIME (auto)

**Features:**
- Self-referencing FK for versioning
- JSON storage for flexible OCR data
- Supports all document types across domains

---

#### 2. **DocumentLinks** (Relationships)
Many-to-many links between documents (e.g., policy → claims, receipt → warranty).

**Columns:**
- `id` - INTEGER PRIMARY KEY AUTOINCREMENT
- `source_document_id` - INTEGER FK → documents(id) CASCADE
- `target_document_id` - INTEGER FK → documents(id) CASCADE
- `link_type` - TEXT ('related', 'supersedes', 'claim', 'receipt')
- `notes` - TEXT
- `deleted_at` - DATETIME
- `created_at` - DATETIME
- `updated_at` - DATETIME

**Constraints:**
- UNIQUE(source_document_id, target_document_id, link_type)

---

#### 3. **Reminders**
Expiry, renewal, review, and custom reminders with snooze support.

**Columns:**
- `id` - INTEGER PRIMARY KEY AUTOINCREMENT
- `document_id` - INTEGER FK → documents(id) CASCADE (nullable)
- `title` - TEXT NOT NULL
- `description` - TEXT
- `reminder_type` - TEXT ('expiry', 'renewal', 'review', 'custom')
- `reminder_date` - DATETIME NOT NULL
- `snooze_until` - DATETIME
- `is_recurring` - BOOLEAN (default: false)
- `recurrence_pattern` - TEXT (JSON: {interval, count})
- `status` - TEXT (default: 'pending') ('pending', 'snoozed', 'completed', 'overdue')
- `completed_at` - DATETIME
- `priority` - INTEGER (default: 0) (0=normal, 1=high, -1=low)
- `deleted_at` - DATETIME
- `created_at` - DATETIME
- `updated_at` - DATETIME

---

#### 4. **Bills**
Recurring and one-off bills/payments with versioning.

**Columns:**
- `id` - INTEGER PRIMARY KEY AUTOINCREMENT
- `document_id` - INTEGER FK → documents(id) SET NULL
- `name` - TEXT NOT NULL
- `description` - TEXT
- `category` - TEXT ('mortgage', 'rent', 'utilities', 'council_tax', etc.)
- `provider` - TEXT
- `amount_cents` - INTEGER (stored in smallest currency unit)
- `currency` - TEXT (default: 'GBP')
- `is_recurring` - BOOLEAN (default: false)
- `frequency` - TEXT ('monthly', 'quarterly', 'annual')
- `next_due_date` - DATETIME
- `last_paid_date` - DATETIME
- `status` - TEXT (default: 'active') ('active', 'paused', 'cancelled')
- `is_auto_pay` - BOOLEAN (default: false)
- `account_number` - TEXT
- `reference_number` - TEXT
- `metadata` - TEXT (JSON for additional fields)
- `deleted_at` - DATETIME
- `version` - INTEGER (default: 1)
- `previous_version_id` - INTEGER FK → bills(id)
- `created_at` - DATETIME
- `updated_at` - DATETIME

**Monetary Storage:**
- All amounts stored as INTEGER (cents/pence)
- Example: £123.45 → 12345

---

#### 5. **Subscriptions**
Digital and lifestyle subscriptions with usage tracking.

**Columns:**
- `id` - INTEGER PRIMARY KEY AUTOINCREMENT
- `document_id` - INTEGER FK → documents(id) SET NULL
- `name` - TEXT NOT NULL
- `description` - TEXT
- `category` - TEXT ('streaming', 'mobile', 'gym', 'cloud_storage', etc.)
- `provider` - TEXT
- `amount_cents` - INTEGER
- `currency` - TEXT (default: 'GBP')
- `billing_frequency` - TEXT ('monthly', 'annual')
- `start_date` - DATETIME
- `renewal_date` - DATETIME
- `cancellation_date` - DATETIME
- `status` - TEXT (default: 'active') ('active', 'trial', 'cancelled', 'expired')
- `auto_renew` - BOOLEAN (default: true)
- `is_trial` - BOOLEAN (default: false)
- `trial_end_date` - DATETIME
- `account_email` - TEXT
- `account_id` - TEXT
- `last_used_date` - DATETIME
- `usage_count` - INTEGER (default: 0)
- `metadata` - TEXT (JSON)
- `deleted_at` - DATETIME
- `version` - INTEGER (default: 1)
- `previous_version_id` - INTEGER FK → subscriptions(id)
- `created_at` - DATETIME
- `updated_at` - DATETIME

---

#### 6. **Policies**
Insurance policies (home, vehicle, life, travel, health, etc.).

**Columns:**
- `id` - INTEGER PRIMARY KEY AUTOINCREMENT
- `document_id` - INTEGER FK → documents(id) SET NULL
- `policy_number` - TEXT NOT NULL
- `policy_name` - TEXT
- `policy_type` - TEXT ('home', 'vehicle', 'life', 'travel', 'health', etc.)
- `provider` - TEXT (insurance company)
- `coverage_type` - TEXT ('buildings', 'contents', 'comprehensive', etc.)
- `coverage_amount_cents` - INTEGER
- `currency` - TEXT (default: 'GBP')
- `premium_amount_cents` - INTEGER
- `premium_frequency` - TEXT ('monthly', 'annual')
- `start_date` - DATETIME
- `renewal_date` - DATETIME
- `expiry_date` - DATETIME
- `cancellation_date` - DATETIME
- `status` - TEXT (default: 'active') ('active', 'expired', 'cancelled')
- `auto_renew` - BOOLEAN (default: true)
- `excess_amount_cents` - INTEGER (deductible)
- `beneficiaries` - TEXT (JSON array)
- `coverage_details` - TEXT (JSON)
- `provider_phone` - TEXT
- `provider_email` - TEXT
- `claim_phone` - TEXT
- `metadata` - TEXT (JSON)
- `deleted_at` - DATETIME
- `version` - INTEGER (default: 1)
- `previous_version_id` - INTEGER FK → policies(id)
- `created_at` - DATETIME
- `updated_at` - DATETIME

---

## File Structure

```
lib/data/local/
├── app_database.dart              # Main database class
├── app_database.g.dart            # Generated by Drift
├── tables/
│   ├── documents.dart             # Documents table definition
│   ├── document_links.dart        # Document links table
│   ├── reminders.dart             # Reminders table
│   ├── bills.dart                 # Bills table
│   ├── subscriptions.dart         # Subscriptions table
│   └── policies.dart              # Policies table
└── daos/
    ├── documents_dao.dart         # Documents DAO + queries
    ├── documents_dao.g.dart       # Generated
    ├── document_links_dao.dart    # Document links DAO
    ├── document_links_dao.g.dart  # Generated
    ├── reminders_dao.dart         # Reminders DAO
    ├── reminders_dao.g.dart       # Generated
    ├── bills_dao.dart             # Bills DAO
    ├── bills_dao.g.dart           # Generated
    ├── subscriptions_dao.dart     # Subscriptions DAO
    ├── subscriptions_dao.g.dart   # Generated
    ├── policies_dao.dart          # Policies DAO
    └── policies_dao.g.dart        # Generated
```

**Total:** 6 tables, 6 DAOs, 19 Dart files (7 source + 12 generated)

---

## Data Access Objects (DAOs)

Each DAO provides comprehensive CRUD operations:

### Common Operations (All DAOs)

#### CREATE
- `create[Entity](companion)` - Insert single entity
- `create[Entities](list)` - Batch insert

#### READ
- `get[Entity]ById(id)` - Get by primary key
- `getAll[Entities]()` - Get all (excluding soft deleted)
- `get[Entities]By[Criteria]()` - Filtered queries
- `watch[Entities]()` - Real-time streams

#### UPDATE
- `update[Entity](entity)` - Full entity update
- `update[Field](id, value)` - Partial update
- Status-specific updates

#### DELETE
- `softDelete[Entity](id)` - Soft delete (sets deleted_at)
- `hardDelete[Entity](id)` - Permanent deletion
- `restore[Entity](id)` - Restore soft deleted

#### STATISTICS
- `count[Entities]()` - Count queries
- `calculate[Metric]()` - Aggregations

---

### DocumentsDao

**Key Methods:**
- `getDocumentsByCategory(category)` - Filter by domain
- `getDocumentsByType(type)` - Filter by document type
- `getDocumentsExpiringBetween(start, end)` - Expiry date range
- `searchDocuments(query)` - Full-text search (title/description)
- `getDocumentVersions(id)` - Version history
- `watchDocumentsByCategory(category)` - Reactive stream

---

### DocumentLinksDao

**Key Methods:**
- `getLinksForDocument(documentId)` - All links (bidirectional)
- `getOutgoingLinks(documentId)` - Source links
- `getIncomingLinks(documentId)` - Target links
- `getLinksByType(linkType)` - Filter by link type
- `areDocumentsLinked(sourceId, targetId)` - Check relationship
- `deleteLinksForDocument(documentId)` - Cascade cleanup

---

### RemindersDao

**Key Methods:**
- `getRemindersForDocument(documentId)` - Document reminders
- `getPendingReminders()` - Active reminders
- `getOverdueReminders()` - Past due reminders
- `getRemindersForToday()` - Today's reminders
- `getRemindersDueBetween(start, end)` - Date range
- `completeReminder(id)` - Mark completed
- `snoozeReminder(id, snoozeUntil)` - Snooze with date
- `markAsOverdue(id)` - Update status
- `countOverdueReminders()` - Overdue count

---

### BillsDao

**Key Methods:**
- `getBillsByCategory(category)` - Category filter
- `getActiveBills()` - Active bills only
- `getRecurringBills()` - Recurring bills
- `getBillsDueThisMonth()` - Monthly view
- `getAutoPayBills()` - Auto-pay filter
- `markBillAsPaid(id, paidDate)` - Payment tracking
- `pauseBill(id)` / `cancelBill(id)` / `activateBill(id)` - Status updates
- `calculateMonthlyTotal()` - Monthly cost (normalized)
- `getBillVersions(id)` - Version history
- `createBillVersion(id, updates)` - New version

**Cost Calculations:**
- Normalizes quarterly → monthly (÷3)
- Normalizes annual → monthly (÷12)

---

### SubscriptionsDao

**Key Methods:**
- `getActiveSubscriptions()` - Active only
- `getTrialSubscriptions()` - Trials only
- `getSubscriptionsRenewingThisMonth()` - Monthly renewals
- `getUnusedSubscriptions(daysSinceLastUse)` - Identify unused
- `cancelSubscription(id, date)` - Cancel with date
- `incrementUsageCount(id)` - Track usage
- `endTrial(id)` - Convert trial → active
- `calculateMonthlyTotal()` - Monthly cost
- `calculateAnnualTotal()` - Annual cost
- `getSubscriptionVersions(id)` - Version history

---

### PoliciesDao

**Key Methods:**
- `getPolicyByNumber(policyNumber)` - Unique lookup
- `getPoliciesByType(policyType)` - Filter by type
- `getPoliciesRenewingThisMonth()` - Monthly renewals
- `getPoliciesExpiringBetween(start, end)` - Expiry tracking
- `renewPolicy(id, newDate)` - Renewal action
- `cancelPolicy(id, date)` - Cancellation
- `calculateMonthlyTotal()` - Monthly premium
- `calculateAnnualTotal()` - Annual premium
- `calculateTotalCoverage()` - Total coverage amount
- `getPolicyVersions(id)` - Version history

---

## Migration Strategy

### Version 1 (Initial)
```dart
onCreate: (Migrator m) async {
  await m.createAll(); // Creates all 6 tables
}
```

### Future Migrations (Example)
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 2) {
    // Example: Add new column
    await m.addColumn(documents, documents.newColumn);
  }
  if (from < 3) {
    // Example: Create index
    await m.createIndex(Index('idx_expiry', 'documents', 'expiry_date'));
  }
}
```

### Database Location
- **macOS/iOS:** `~/Library/Application Support/[bundle_id]/mysmartadmin.sqlite`
- **Android:** `/data/data/[package]/databases/mysmartadmin.sqlite`
- **Linux:** `~/.local/share/[app]/mysmartadmin.sqlite`
- **Windows:** `%APPDATA%/[app]/mysmartadmin.sqlite`

---

## Design Patterns Implemented

### 1. Soft Delete Pattern
All tables include `deleted_at` column:
- NULL = active record
- TIMESTAMP = soft deleted
- Allows recovery and audit trails
- All queries filter by `deleted_at IS NULL`
- Separate methods for hard delete

### 2. Versioning Pattern
Applied to: Bills, Subscriptions, Policies, Documents
- `version` column (increments)
- `previous_version_id` (self-referencing FK)
- Enables audit trails and change history
- Can revert to previous versions

### 3. JSON Columns
Flexible storage for:
- `extracted_data` (OCR results)
- `metadata` (domain-specific fields)
- `recurrence_pattern` (scheduling rules)
- `beneficiaries` (list of beneficiaries)
- `coverage_details` (policy details)

### 4. Monetary Values
**INTEGER storage (cents/pence):**
- Avoids floating-point precision issues
- Example: £123.45 stored as 12345
- Currency column tracks denomination

### 5. Reactive Streams
- `watch*()` methods return `Stream<List<Entity>>`
- UI automatically updates on data changes
- Efficient change detection

---

## Query Examples

### Example 1: Get Expiring Documents
```dart
final expiringDocs = await database.documentsDao
  .getDocumentsExpiringBetween(
    DateTime.now(),
    DateTime.now().add(Duration(days: 30)),
  );
```

### Example 2: Calculate Monthly Costs
```dart
final billsCost = await database.billsDao.calculateMonthlyTotal();
final subsCost = await database.subscriptionsDao.calculateMonthlyTotal();
final policyCost = await database.policiesDao.calculateMonthlyTotal();
final totalMonthly = billsCost + subsCost + policyCost;
// All values in cents/pence
print('Total: £${totalMonthly / 100}');
```

### Example 3: Reactive UI Updates
```dart
StreamBuilder<List<ReminderEntity>>(
  stream: database.remindersDao.watchPendingReminders(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final reminders = snapshot.data!;
    return ListView.builder(...);
  },
);
```

### Example 4: Link Documents
```dart
// Link insurance policy to claim document
await database.documentLinksDao.createLink(
  DocumentLinksCompanion(
    sourceDocumentId: Value(policyDocId),
    targetDocumentId: Value(claimDocId),
    linkType: Value('claim'),
    notes: Value('Claim submitted 2024-01-15'),
  ),
);
```

---

## Verification

### Code Generation
```bash
✅ dart run build_runner build --delete-conflicting-outputs
   Result: 112 outputs generated
   Warnings: 2 (duplicate reference name - non-blocking)
```

### Static Analysis
```bash
✅ flutter analyze lib/data/
   Result: 6 info-level suggestions (use_super_parameters)
   No errors or warnings
```

### Database File Created
```bash
✅ Database path: mysmartadmin.sqlite
   Location: Application Documents directory
   Foreign keys: ENABLED
```

---

## What's NOT Included (By Design)

❌ UI components (as per requirements)  
❌ Business logic / services  
❌ AI features  
❌ Open Banking integration  
❌ Backend / cloud sync  
❌ Seed data  
❌ Tests (deferred)  
❌ Encryption (future enhancement)  

---

## Dependencies Added

```yaml
dependencies:
  drift: ^2.23.0              # Type-safe SQLite
  sqlite3_flutter_libs: ^0.5.24  # Native SQLite
  path_provider: ^2.1.5       # File system paths
  path: ^1.9.0                # Path utilities

dev_dependencies:
  drift_dev: ^2.23.0          # Code generator
  build_runner: ^2.4.14       # Build tool
```

---

## Usage Example

### Initialize Database
```dart
import 'package:mysmartadmin/data/local/app_database.dart';

final database = AppDatabase();

// Access DAOs
final documentsDao = database.documentsDao;
final billsDao = database.billsDao;
final remindersDao = database.remindersDao;
```

### Create a Bill
```dart
final billId = await billsDao.createBill(
  BillsCompanion.insert(
    name: 'Electricity Bill',
    category: 'utilities',
    provider: Value('British Gas'),
    amountCents: 8500, // £85.00
    currency: Value('GBP'),
    isRecurring: Value(true),
    frequency: Value('monthly'),
    nextDueDate: Value(DateTime.now().add(Duration(days: 30))),
    status: Value('active'),
  ),
);
```

### Create a Reminder
```dart
await remindersDao.createReminder(
  RemindersCompanion.insert(
    documentId: Value(docId),
    title: 'Passport Renewal',
    reminderType: 'expiry',
    reminderDate: expiryDate.subtract(Duration(days: 90)),
    priority: Value(1), // high priority
  ),
);
```

---

## Next Steps (B9 & Beyond)

Ready for:
- **B9:** Repository layer (business logic abstraction)
- **B10:** State management integration (Riverpod providers)
- **B11:** UI implementation (CRUD screens)
- **B12:** Document scanning & OCR
- **B13:** Search & query intelligence
- **B14:** Reports & analytics
- **B15:** Data export/backup

---

## Performance Considerations

### Indexes (Future)
Consider indexes for:
- `documents.expiry_date` (frequent date queries)
- `documents.category` (domain filtering)
- `reminders.reminder_date` (scheduling queries)
- `bills.next_due_date` (due date queries)

### Query Optimization
- All DAOs filter soft deleted by default
- Batch operations for bulk inserts
- Stream queries for reactive UI
- Selective column reads for large tables

---

## Deliverables Checklist

- [x] Drift dependencies added to pubspec.yaml
- [x] 6 table definitions created (documents, links, reminders, bills, subs, policies)
- [x] Soft delete pattern applied to all tables
- [x] Versioning pattern applied where specified
- [x] INTEGER monetary values (cents/pence)
- [x] JSON columns for flexible data
- [x] 6 DAOs with comprehensive CRUD operations
- [x] Foreign key constraints configured
- [x] Migration v1 implemented
- [x] Code generation successful (112 outputs)
- [x] Static analysis passed (no errors)
- [x] Documentation complete

**Step B8: COMPLETE** ✅

---

## Notes

1. **Foreign Keys**: Enabled via `PRAGMA foreign_keys = ON` in `beforeOpen`
2. **Timestamps**: `created_at` and `updated_at` auto-populated via Drift
3. **Type Safety**: All queries are type-safe at compile time
4. **Null Safety**: Full Dart null-safety compliance
5. **Cross-Platform**: Works on iOS, Android, macOS, Linux, Windows
6. **No Network**: Database operations are 100% local

---

**End of B8 Implementation**

