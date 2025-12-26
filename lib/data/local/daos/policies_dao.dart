import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/policies.dart';

part 'policies_dao.g.dart';

/// Data Access Object for Insurance Policies
/// 
/// Manages all types of insurance policies
@DriftAccessor(tables: [Policies])
class PoliciesDao extends DatabaseAccessor<AppDatabase> with _$PoliciesDaoMixin {
  PoliciesDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new policy
  Future<int> createPolicy(PoliciesCompanion policy) {
    return into(policies).insert(policy);
  }

  /// Create multiple policies
  Future<void> createPolicies(List<PoliciesCompanion> policyList) async {
    await batch((batch) {
      batch.insertAll(policies, policyList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a policy by ID
  Future<PolicyEntity?> getPolicyById(int id) {
    return (select(policies)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get policy by policy number
  Future<PolicyEntity?> getPolicyByNumber(String policyNumber) {
    return (select(policies)
          ..where((t) => t.policyNumber.equals(policyNumber))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all policies
  Future<List<PolicyEntity>> getAllPolicies() {
    return (select(policies)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get policies by type
  Future<List<PolicyEntity>> getPoliciesByType(String policyType) {
    return (select(policies)
          ..where((t) => t.policyType.equals(policyType))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get policies by provider
  Future<List<PolicyEntity>> getPoliciesByProvider(String provider) {
    return (select(policies)
          ..where((t) => t.provider.equals(provider))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get policies by status
  Future<List<PolicyEntity>> getPoliciesByStatus(String status) {
    return (select(policies)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get active policies
  Future<List<PolicyEntity>> getActivePolicies() {
    return getPoliciesByStatus('active');
  }

  /// Get policies renewing within a date range
  Future<List<PolicyEntity>> getPoliciesRenewingBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(policies)
          ..where((t) => t.renewalDate.isBetweenValues(start, end))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .get();
  }

  /// Get policies expiring within a date range
  Future<List<PolicyEntity>> getPoliciesExpiringBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(policies)
          ..where((t) => t.expiryDate.isBetweenValues(start, end))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.expiryDate)]))
        .get();
  }

  /// Get policies renewing this month
  Future<List<PolicyEntity>> getPoliciesRenewingThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getPoliciesRenewingBetween(startOfMonth, endOfMonth);
  }

  /// Get policies with auto-renew enabled
  Future<List<PolicyEntity>> getAutoRenewPolicies() {
    return (select(policies)
          ..where((t) => t.autoRenew.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull()))
        .get();
  }

  /// Stream all policies
  Stream<List<PolicyEntity>> watchAllPolicies() {
    return (select(policies)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .watch();
  }

  /// Stream policies by type
  Stream<List<PolicyEntity>> watchPoliciesByType(String policyType) {
    return (select(policies)
          ..where((t) => t.policyType.equals(policyType))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .watch();
  }

  /// Stream active policies
  Stream<List<PolicyEntity>> watchActivePolicies() {
    return (select(policies)
          ..where((t) => t.status.equals('active'))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.previousVersionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.renewalDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a policy
  Future<bool> updatePolicy(PolicyEntity policy) {
    return update(policies).replace(policy);
  }

  /// Update policy status
  Future<int> updatePolicyStatus(int id, String status) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Renew a policy
  Future<int> renewPolicy(int id, DateTime newRenewalDate) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        renewalDate: Value(newRenewalDate),
        status: const Value('active'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Cancel a policy
  Future<int> cancelPolicy(int id, DateTime cancellationDate) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        status: const Value('cancelled'),
        cancellationDate: Value(cancellationDate),
        autoRenew: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update renewal date
  Future<int> updateRenewalDate(int id, DateTime renewalDate) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        renewalDate: Value(renewalDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update expiry date
  Future<int> updateExpiryDate(int id, DateTime expiryDate) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        expiryDate: Value(expiryDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggle auto-renew
  Future<int> toggleAutoRenew(int id, bool autoRenew) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        autoRenew: Value(autoRenew),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update premium amount
  Future<int> updatePremiumAmount(int id, int premiumAmountCents) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        premiumAmountCents: Value(premiumAmountCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a policy
  Future<int> softDeletePolicy(int id) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      PoliciesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a policy
  Future<int> hardDeletePolicy(int id) {
    return (delete(policies)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted policy
  Future<int> restorePolicy(int id) {
    return (update(policies)..where((t) => t.id.equals(id))).write(
      const PoliciesCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total monthly insurance cost (in cents)
  Future<int> calculateMonthlyTotal() async {
    final activePolicies = await getActivePolicies();
    int total = 0;

    for (final policy in activePolicies) {
      // Convert to monthly equivalent
      switch (policy.premiumFrequency) {
        case 'monthly':
          total += policy.premiumAmountCents;
          break;
        case 'annual':
          total += (policy.premiumAmountCents / 12).round();
          break;
      }
    }

    return total;
  }

  /// Calculate annual insurance cost (in cents)
  Future<int> calculateAnnualTotal() async {
    final activePolicies = await getActivePolicies();
    int total = 0;

    for (final policy in activePolicies) {
      // Convert to annual equivalent
      switch (policy.premiumFrequency) {
        case 'monthly':
          total += policy.premiumAmountCents * 12;
          break;
        case 'annual':
          total += policy.premiumAmountCents;
          break;
      }
    }

    return total;
  }

  /// Calculate total coverage amount (in cents)
  Future<int> calculateTotalCoverage() async {
    final activePolicies = await getActivePolicies();
    int total = 0;

    for (final policy in activePolicies) {
      if (policy.coverageAmountCents != null) {
        total += policy.coverageAmountCents!;
      }
    }

    return total;
  }

  /// Count policies by type
  Future<int> countPoliciesByType(String policyType) async {
    final query = selectOnly(policies)
      ..addColumns([policies.id.count()])
      ..where(policies.policyType.equals(policyType))
      ..where(policies.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(policies.id.count()) ?? 0;
  }

  /// Count active policies
  Future<int> countActivePolicies() async {
    final query = selectOnly(policies)
      ..addColumns([policies.id.count()])
      ..where(policies.status.equals('active'))
      ..where(policies.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(policies.id.count()) ?? 0;
  }

  /// Count policies by provider
  Future<int> countPoliciesByProvider(String provider) async {
    final query = selectOnly(policies)
      ..addColumns([policies.id.count()])
      ..where(policies.provider.equals(provider))
      ..where(policies.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(policies.id.count()) ?? 0;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get policy versions
  Future<List<PolicyEntity>> getPolicyVersions(int policyId) {
    return (select(policies)
          ..where((t) =>
              t.id.equals(policyId) |
              t.previousVersionId.equals(policyId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of a policy
  Future<int> createPolicyVersion(
    int existingPolicyId,
    PoliciesCompanion updates,
  ) async {
    final existing = await getPolicyById(existingPolicyId);
    if (existing == null) throw Exception('Policy not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingPolicyId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(policies).insert(newVersion);
  }
}

