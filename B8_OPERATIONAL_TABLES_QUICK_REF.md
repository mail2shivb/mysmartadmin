# B8: Operational Tables - Quick Reference

## Tables Added ✅

| Table | Columns | Foreign Keys | Special Features |
|-------|---------|--------------|------------------|
| **compliance_records** | 25 | documents, properties, vehicles | Status tracking, JSON findings |
| **service_records** | 30 | documents, properties, vehicles, home_assets | Warranty tracking, cost breakdown |
| **claims** | 32 | documents, policies, properties, vehicles | Versioning, lifecycle tracking |
| **tasks** | 23 | documents, properties, vehicles, home_assets | Priority, recurring, checklist |

## DAOs Added ✅

| DAO | CRUD | Streams | Statistics | Special |
|-----|------|---------|------------|---------|
| **ComplianceRecordsDao** | ✅ | 5 | 4 | Expiry tracking |
| **ServiceRecordsDao** | ✅ | 3 | 6 | Warranty calculations |
| **ClaimsDao** | ✅ | 3 | 5 | Versioning support |
| **TasksDao** | ✅ | 4 | 3 | Priority management |

## Common Operations

### Create
```dart
// Compliance Record
await db.complianceRecordsDao.createComplianceRecord(...);

// Service Record
await db.serviceRecordsDao.createServiceRecord(...);

// Claim
await db.claimsDao.createClaim(...);

// Task
await db.tasksDao.createTask(...);
```

### Read
```dart
// Get by entity
await db.complianceRecordsDao.getComplianceRecordsForVehicle(vehicleId);
await db.serviceRecordsDao.getServiceRecordsForProperty(propertyId);
await db.claimsDao.getClaimsForPolicy(policyId);
await db.tasksDao.getTasksForHomeAsset(assetId);

// Get by status
await db.complianceRecordsDao.getValidComplianceRecords();
await db.serviceRecordsDao.getScheduledServiceRecords();
await db.claimsDao.getApprovedClaims();
await db.tasksDao.getPendingTasks();
```

### Watch (Streams)
```dart
// Reactive streams
db.complianceRecordsDao.watchComplianceRecordsForVehicle(vehicleId);
db.serviceRecordsDao.watchServiceRecordsByStatus('scheduled');
db.claimsDao.watchClaimsForPolicy(policyId);
db.tasksDao.watchOverdueTasks();
```

### Update
```dart
// Status updates
await db.complianceRecordsDao.markAsExpired(id);
await db.serviceRecordsDao.markServiceAsCompleted(id, DateTime.now());
await db.claimsDao.markClaimAsPaid(id, DateTime.now(), 100000);
await db.tasksDao.markTaskAsCompleted(id);
```

### Statistics
```dart
// Cost calculations
final complianceCosts = await db.complianceRecordsDao.calculateAnnualComplianceCosts();
final serviceCosts = await db.serviceRecordsDao.calculateTotalServiceCosts();
final paidClaims = await db.claimsDao.calculateTotalPaidAmount();

// Counts and rates
final overdueCount = await db.tasksDao.countOverdueTasks();
final successRate = await db.claimsDao.calculateClaimSuccessRate();
```

## Key Features

### Monetary Values
All amounts stored as INTEGER (cents/pence):
```dart
costCents: 8550  // £85.50
```

### JSON Storage
Flexible data storage:
```dart
findings: jsonEncode(['Advisory: Slight corrosion', 'Warning: Tyre wear'])
partsReplaced: jsonEncode(['Oil Filter', 'Air Filter'])
checklist: jsonEncode([{task: 'Review', done: false}])
```

### Soft Delete
All tables support recovery:
```dart
await dao.softDelete(id);      // Mark as deleted
await dao.restore(id);          // Restore
await dao.hardDelete(id);       // Permanent
```

### Versioning (Claims)
Audit trail support:
```dart
final newVersion = await db.claimsDao.createClaimVersion(existingId, updates);
final history = await db.claimsDao.getClaimVersions(existingId);
```

## Status Values

### ComplianceRecords
- `valid` - Currently valid
- `expired` - Past expiry date
- `due` - Due for renewal
- `failed` - Failed inspection

### ServiceRecords
- `scheduled` - Appointment booked
- `in_progress` - Currently being serviced
- `completed` - Service finished
- `cancelled` - Appointment cancelled

### Claims
- `draft` - Being prepared
- `submitted` - Sent to insurer
- `under_review` - Being assessed
- `approved` - Claim approved
- `rejected` - Claim rejected
- `paid` - Payment received
- `closed` - Claim closed

### Tasks
- `pending` - Not started
- `in_progress` - Being worked on
- `completed` - Finished
- `cancelled` - No longer needed
- `overdue` - Past due date

## Database Access

```dart
import 'package:mysmartadmin/data/local/app_database.dart';

final db = AppDatabase();

// Access DAOs
final complianceDao = db.complianceRecordsDao;
final serviceDao = db.serviceRecordsDao;
final claimsDao = db.claimsDao;
final tasksDao = db.tasksDao;
```

## Verification

✅ Code generation: `dart run build_runner build`  
✅ Static analysis: `flutter analyze lib/data/local/`  
✅ No errors, 15 info suggestions (style only)  
✅ All 14 tables registered  
✅ All 14 DAOs registered  
✅ Schema version: 1

---

**Status:** Production Ready ✅  
**Date:** 2025-12-26

