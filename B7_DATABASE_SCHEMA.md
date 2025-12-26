# B7: Database Schema (Approved)

## Entity Relationship Summary

Based on the implementation in B8, this document serves as the schema reference.

---

## Core Entities

### 1. Documents (Central Hub)
**Purpose:** Store all document metadata across domains  
**Pattern:** Soft delete + Versioning  
**Key Fields:** title, category, document_type, expiry_date, file_path

### 2. DocumentLinks (Relationships)
**Purpose:** Many-to-many document relationships  
**Pattern:** Soft delete  
**Key Fields:** source_document_id, target_document_id, link_type

### 3. Reminders (Alerts)
**Purpose:** Expiry, renewal, and custom reminders  
**Pattern:** Soft delete  
**Key Fields:** reminder_date, reminder_type, status, is_recurring

### 4. Bills (Recurring Payments)
**Purpose:** Track household bills and payments  
**Pattern:** Soft delete + Versioning  
**Key Fields:** amount_cents, frequency, next_due_date, category

### 5. Subscriptions (Digital Services)
**Purpose:** Track subscriptions with usage  
**Pattern:** Soft delete + Versioning  
**Key Fields:** amount_cents, renewal_date, is_trial, last_used_date

### 6. Policies (Insurance)
**Purpose:** Track all insurance policies  
**Pattern:** Soft delete + Versioning  
**Key Fields:** policy_number, premium_amount_cents, renewal_date, coverage_amount_cents

---

## Relationships

```
Documents (1) ←→ (N) DocumentLinks (N) ←→ (1) Documents
Documents (1) ←→ (N) Reminders
Documents (1) ←→ (N) Bills
Documents (1) ←→ (N) Subscriptions
Documents (1) ←→ (N) Policies

Bills (1) ←→ (N) Bills (versioning - self-referencing)
Subscriptions (1) ←→ (N) Subscriptions (versioning)
Policies (1) ←→ (N) Policies (versioning)
Documents (1) ←→ (N) Documents (versioning)
```

---

## Monetary Values

**Storage:** INTEGER (cents/pence)  
**Fields:**
- `bills.amount_cents`
- `subscriptions.amount_cents`
- `policies.premium_amount_cents`
- `policies.coverage_amount_cents`
- `policies.excess_amount_cents`

**Example:** £123.45 → stored as `12345`

---

## JSON Columns

**Purpose:** Flexible storage for domain-specific data

**Fields:**
- `documents.extracted_data` - OCR results
- `bills.metadata` - Additional bill data
- `subscriptions.metadata` - Additional subscription data
- `policies.metadata` - Additional policy data
- `policies.beneficiaries` - List of beneficiaries
- `policies.coverage_details` - Detailed coverage info
- `reminders.recurrence_pattern` - Scheduling rules

---

## Soft Delete Pattern

**All tables include:**
- `deleted_at` DATETIME (NULL = active)

**Behavior:**
- Default queries filter `deleted_at IS NULL`
- Separate methods for soft/hard delete
- Restore capability via setting `deleted_at = NULL`

---

## Versioning Pattern

**Applied to:** Documents, Bills, Subscriptions, Policies

**Fields:**
- `version` INTEGER (default: 1)
- `previous_version_id` INTEGER FK (self-referencing)

**Behavior:**
- New version created when significant changes occur
- Links to previous version for audit trail
- Can retrieve full version history

---

## Status Enums

### Reminders
- `pending` - Not yet triggered
- `snoozed` - User postponed
- `completed` - User marked done
- `overdue` - Past due date

### Bills
- `active` - Currently active
- `paused` - Temporarily suspended
- `cancelled` - Permanently cancelled

### Subscriptions
- `active` - Currently subscribed
- `trial` - In trial period
- `cancelled` - User cancelled
- `expired` - Subscription expired

### Policies
- `active` - Policy in force
- `expired` - Policy expired
- `cancelled` - Policy cancelled

---

## Categories / Types

### Document Categories (Domains)
- `property` - Property & Home
- `vehicle` - Vehicles & Transport
- `finance` - Finance & Banking
- `insurance` - Insurance & Protection
- `subscription` - Subscriptions
- `identity` - Identity & Legal
- `employment` - Employment
- `general` - General documents

### Bill Categories
- `mortgage` / `rent`
- `council_tax`
- `utilities` (gas, electricity, water)
- `broadband`
- `tv_licence`
- etc.

### Subscription Categories
- `streaming` (Netflix, Disney+, etc.)
- `mobile` (phone contracts)
- `gym` & `fitness`
- `cloud_storage`
- etc.

### Policy Types
- `home` (buildings, contents)
- `vehicle` (car, motorcycle)
- `life`
- `health`
- `travel`
- `pet`
- etc.

---

## Foreign Key Actions

### CASCADE (Delete child when parent deleted)
- `document_links.source_document_id` → `documents.id`
- `document_links.target_document_id` → `documents.id`
- `reminders.document_id` → `documents.id`

### SET NULL (Keep child, remove reference)
- `bills.document_id` → `documents.id`
- `subscriptions.document_id` → `documents.id`
- `policies.document_id` → `documents.id`

---

## Indexes (Recommended - Future)

```sql
CREATE INDEX idx_documents_expiry ON documents(expiry_date);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_reminders_date ON reminders(reminder_date);
CREATE INDEX idx_bills_due_date ON bills(next_due_date);
CREATE INDEX idx_subscriptions_renewal ON subscriptions(renewal_date);
CREATE INDEX idx_policies_renewal ON policies(renewal_date);
CREATE INDEX idx_documents_deleted ON documents(deleted_at);
```

---

**Schema Version:** v1  
**Implementation:** B8  
**Status:** ✅ Approved & Implemented

