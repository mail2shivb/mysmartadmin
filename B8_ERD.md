# B8: Database Entity Relationship Diagram

## Visual Schema Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          DOCUMENTS (Core Hub)                        │
├─────────────────────────────────────────────────────────────────────┤
│ • id (PK)                    • file_path                            │
│ • title                      • file_type                            │
│ • description                • file_size_bytes                      │
│ • document_type              • extracted_data (JSON)                │
│ • category (domain)          • tags                                 │
│ • document_date              • deleted_at (soft delete)             │
│ • expiry_date                • version                              │
│ • reminder_date              • previous_version_id (FK → documents) │
│ • created_at / updated_at                                           │
└─────────────────────────────────────────────────────────────────────┘
         ↓ (1:N)        ↓ (1:N)        ↓ (1:N)        ↓ (1:N)
         │              │              │              │
    ┌────────┐     ┌─────────┐    ┌──────┐      ┌──────────┐
    │ LINKS  │     │REMINDERS│    │BILLS │      │ POLICIES │
    └────────┘     └─────────┘    └──────┘      └──────────┘
         │              │              │              │
         │              │              │              │
         ↓              ↓              ↓              ↓

┌──────────────────────────┐  ┌──────────────────────────┐
│   DOCUMENT_LINKS         │  │      REMINDERS           │
├──────────────────────────┤  ├──────────────────────────┤
│ • id (PK)                │  │ • id (PK)                │
│ • source_document_id (FK)│  │ • document_id (FK)       │
│ • target_document_id (FK)│  │ • title                  │
│ • link_type              │  │ • description            │
│ • notes                  │  │ • reminder_type          │
│ • deleted_at             │  │ • reminder_date          │
│ • created_at / updated_at│  │ • snooze_until           │
│                          │  │ • is_recurring           │
│ CASCADE on parent delete │  │ • recurrence_pattern (JSON)│
└──────────────────────────┘  │ • status                 │
                              │ • completed_at           │
                              │ • priority               │
                              │ • deleted_at             │
                              │ • created_at / updated_at│
                              │                          │
                              │ CASCADE on doc delete    │
                              └──────────────────────────┘

┌──────────────────────────┐  ┌──────────────────────────┐
│        BILLS             │  │     SUBSCRIPTIONS        │
├──────────────────────────┤  ├──────────────────────────┤
│ • id (PK)                │  │ • id (PK)                │
│ • document_id (FK)       │  │ • document_id (FK)       │
│ • name                   │  │ • name                   │
│ • description            │  │ • description            │
│ • category               │  │ • category               │
│ • provider               │  │ • provider               │
│ • amount_cents (INTEGER) │  │ • amount_cents (INTEGER) │
│ • currency               │  │ • currency               │
│ • is_recurring           │  │ • billing_frequency      │
│ • frequency              │  │ • start_date             │
│ • next_due_date          │  │ • renewal_date           │
│ • last_paid_date         │  │ • cancellation_date      │
│ • status                 │  │ • status                 │
│ • is_auto_pay            │  │ • auto_renew             │
│ • account_number         │  │ • is_trial               │
│ • reference_number       │  │ • trial_end_date         │
│ • metadata (JSON)        │  │ • account_email          │
│ • deleted_at             │  │ • account_id             │
│ • version                │  │ • last_used_date         │
│ • previous_version_id    │  │ • usage_count            │
│ • created_at / updated_at│  │ • metadata (JSON)        │
│                          │  │ • deleted_at             │
│ SET NULL on doc delete   │  │ • version                │
└──────────────────────────┘  │ • previous_version_id    │
                              │ • created_at / updated_at│
                              │                          │
                              │ SET NULL on doc delete   │
                              └──────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│                        POLICIES                           │
├───────────────────────────────────────────────────────────┤
│ • id (PK)                    • start_date                 │
│ • document_id (FK)           • renewal_date               │
│ • policy_number              • expiry_date                │
│ • policy_name                • cancellation_date          │
│ • policy_type                • status                     │
│ • provider                   • auto_renew                 │
│ • coverage_type              • excess_amount_cents        │
│ • coverage_amount_cents      • beneficiaries (JSON)       │
│ • currency                   • coverage_details (JSON)    │
│ • premium_amount_cents       • provider_phone            │
│ • premium_frequency          • provider_email            │
│ • deleted_at                 • claim_phone               │
│ • version                    • metadata (JSON)           │
│ • previous_version_id        • created_at / updated_at   │
│                                                           │
│ SET NULL on doc delete                                    │
└───────────────────────────────────────────────────────────┘
```

---

## Relationship Types

### 1:N (One-to-Many)
- **Documents → Document Links** (source)
- **Documents → Document Links** (target)
- **Documents → Reminders**
- **Documents → Bills**
- **Documents → Subscriptions**
- **Documents → Policies**

### Self-Referencing (Versioning)
- **Documents → Documents** (previous_version_id)
- **Bills → Bills** (previous_version_id)
- **Subscriptions → Subscriptions** (previous_version_id)
- **Policies → Policies** (previous_version_id)

---

## Delete Behaviors

### CASCADE
When parent document is deleted, children are automatically deleted:
- **document_links** (both source and target references)
- **reminders** (document-linked reminders)

### SET NULL
When parent document is deleted, FK is set to NULL:
- **bills.document_id** (bill persists without document)
- **subscriptions.document_id** (subscription persists)
- **policies.document_id** (policy persists)

---

## Soft Delete Implementation

All tables include `deleted_at` timestamp:

```dart
// Active records
WHERE deleted_at IS NULL

// Soft deleted records
WHERE deleted_at IS NOT NULL

// Soft delete operation
UPDATE table SET deleted_at = NOW() WHERE id = ?

// Restore operation
UPDATE table SET deleted_at = NULL WHERE id = ?
```

---

## Versioning Pattern

Applied to: Documents, Bills, Subscriptions, Policies

```
Version 1 (Original)
┌──────────┐
│ id: 100  │
│ version:1│
│ prev: ø  │
└──────────┘
     ↑
     │ (previous_version_id)
     │
Version 2 (Updated)
┌──────────┐
│ id: 101  │
│ version:2│
│ prev: 100│
└──────────┘
     ↑
     │
Version 3 (Updated)
┌──────────┐
│ id: 102  │
│ version:3│
│ prev: 101│
└──────────┘
```

---

## Data Types

### Text Fields
- VARCHAR-equivalent via `text()` constraints
- Example: `title` (1-255 chars)

### Integer Fields
- **Primary Keys:** Auto-incrementing integers
- **Foreign Keys:** Integer references
- **Monetary:** Cents/pence (e.g., £10.50 → 1050)
- **Counters:** Usage counts, versions

### DateTime Fields
- **Timestamps:** created_at, updated_at
- **Dates:** expiry_date, renewal_date, due_date
- **Soft Delete:** deleted_at (nullable)

### Boolean Fields
- **Flags:** is_recurring, auto_renew, is_trial
- Stored as INTEGER (0/1) in SQLite

### JSON Fields
- **Flexible Storage:** metadata, extracted_data
- **Arrays:** tags, beneficiaries
- **Complex Objects:** coverage_details, recurrence_pattern

---

## Indexes (Recommended for Future)

```sql
-- Performance indexes
CREATE INDEX idx_documents_expiry ON documents(expiry_date);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_deleted ON documents(deleted_at);

CREATE INDEX idx_reminders_date ON reminders(reminder_date);
CREATE INDEX idx_reminders_status ON reminders(status);

CREATE INDEX idx_bills_due ON bills(next_due_date);
CREATE INDEX idx_bills_category ON bills(category);

CREATE INDEX idx_subs_renewal ON subscriptions(renewal_date);
CREATE INDEX idx_subs_status ON subscriptions(status);

CREATE INDEX idx_policies_renewal ON policies(renewal_date);
CREATE INDEX idx_policies_type ON policies(policy_type);
```

---

## Query Patterns

### Find Documents Expiring Soon
```dart
final docs = await documentsDao.getDocumentsExpiringBetween(
  DateTime.now(),
  DateTime.now().add(Duration(days: 30)),
);
```

### Calculate Total Monthly Costs
```dart
final bills = await billsDao.calculateMonthlyTotal();
final subs = await subscriptionsDao.calculateMonthlyTotal();
final policies = await policiesDao.calculateMonthlyTotal();
final total = bills + subs + policies; // in cents
```

### Find Overdue Reminders
```dart
final overdue = await remindersDao.getOverdueReminders();
```

### Track Document Relationships
```dart
final links = await documentLinksDao.getLinksForDocument(docId);
```

### Monitor Usage
```dart
final unused = await subscriptionsDao.getUnusedSubscriptions(90);
```

---

## Storage Locations

### macOS/iOS
```
~/Library/Application Support/com.example.mysmartadmin/
  └── mysmartadmin.sqlite
```

### Android
```
/data/data/com.example.mysmartadmin/databases/
  └── mysmartadmin.sqlite
```

### Linux
```
~/.local/share/mysmartadmin/
  └── mysmartadmin.sqlite
```

### Windows
```
%APPDATA%/mysmartadmin/
  └── mysmartadmin.sqlite
```

---

## Database Size Estimates

### Empty Database
- **Size:** ~100 KB (schema only)

### 1,000 Documents
- **Size:** ~5-10 MB (depending on JSON data)

### 10,000 Documents
- **Size:** ~50-100 MB

### With Large OCR Data
- **Size:** Can grow significantly based on `extracted_data` JSON

**Note:** File storage (PDFs, images) is separate on filesystem, not in DB.

---

_End of Entity Relationship Diagram_

