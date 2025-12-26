import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/claims.dart';

part 'claims_dao.g.dart';

/// Data Access Object for Claims
/// 
/// Manages insurance and warranty claims
@DriftAccessor(tables: [Claims])
class ClaimsDao extends DatabaseAccessor<AppDatabase> with _$ClaimsDaoMixin {
  ClaimsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new claim
  Future<int> createClaim(ClaimsCompanion claim) {
    return into(claims).insert(claim);
  }

  /// Create multiple claims
  Future<void> createClaims(List<ClaimsCompanion> claimList) async {
    await batch((batch) {
      batch.insertAll(claims, claimList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a claim by ID
  Future<ClaimEntity?> getClaimById(int id) {
    return (select(claims)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all claims
  Future<List<ClaimEntity>> getAllClaims() {
    return (select(claims)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get claim by claim number
  Future<ClaimEntity?> getClaimByClaimNumber(String claimNumber) {
    return (select(claims)
          ..where((t) => t.claimNumber.equals(claimNumber))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get claims by type
  Future<List<ClaimEntity>> getClaimsByType(String claimType) {
    return (select(claims)
          ..where((t) => t.claimType.equals(claimType))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get claims by category
  Future<List<ClaimEntity>> getClaimsByCategory(String category) {
    return (select(claims)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get claims by status
  Future<List<ClaimEntity>> getClaimsByStatus(String status) {
    return (select(claims)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get submitted claims
  Future<List<ClaimEntity>> getSubmittedClaims() {
    return getClaimsByStatus('submitted');
  }

  /// Get under review claims
  Future<List<ClaimEntity>> getUnderReviewClaims() {
    return getClaimsByStatus('under_review');
  }

  /// Get approved claims
  Future<List<ClaimEntity>> getApprovedClaims() {
    return getClaimsByStatus('approved');
  }

  /// Get rejected claims
  Future<List<ClaimEntity>> getRejectedClaims() {
    return getClaimsByStatus('rejected');
  }

  /// Get paid claims
  Future<List<ClaimEntity>> getPaidClaims() {
    return getClaimsByStatus('paid');
  }

  /// Get claims for a policy
  Future<List<ClaimEntity>> getClaimsForPolicy(int policyId) {
    return (select(claims)
          ..where((t) => t.policyId.equals(policyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get claims for a property
  Future<List<ClaimEntity>> getClaimsForProperty(int propertyId) {
    return (select(claims)
          ..where((t) => t.propertyId.equals(propertyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get claims for a vehicle
  Future<List<ClaimEntity>> getClaimsForVehicle(int vehicleId) {
    return (select(claims)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get claims submitted this year
  Future<List<ClaimEntity>> getClaimsSubmittedThisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    
    return (select(claims)
          ..where((t) => t.submittedDate.isBiggerOrEqualValue(startOfYear))
          ..where((t) => t.submittedDate.isSmallerOrEqualValue(endOfYear))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Get open claims (not closed)
  Future<List<ClaimEntity>> getOpenClaims() {
    return (select(claims)
          ..where((t) => t.status.isNotValue('closed'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .get();
  }

  /// Stream all claims
  Stream<List<ClaimEntity>> watchAllClaims() {
    return (select(claims)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .watch();
  }

  /// Stream claims by status
  Stream<List<ClaimEntity>> watchClaimsByStatus(String status) {
    return (select(claims)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .watch();
  }

  /// Stream claims for a policy
  Stream<List<ClaimEntity>> watchClaimsForPolicy(int policyId) {
    return (select(claims)
          ..where((t) => t.policyId.equals(policyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.submittedDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a claim
  Future<bool> updateClaim(ClaimEntity claim) {
    return update(claims).replace(claim);
  }

  /// Update claim status
  Future<int> updateClaimStatus(int id, String status) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark claim as submitted
  Future<int> markClaimAsSubmitted(int id, DateTime submittedDate) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        status: const Value('submitted'),
        submittedDate: Value(submittedDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark claim as approved
  Future<int> markClaimAsApproved(int id, DateTime approvedDate, int approvedAmountCents) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        status: const Value('approved'),
        outcome: const Value('approved'),
        approvedDate: Value(approvedDate),
        approvedAmountCents: Value(approvedAmountCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark claim as rejected
  Future<int> markClaimAsRejected(int id) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        status: const Value('rejected'),
        outcome: const Value('rejected'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark claim as paid
  Future<int> markClaimAsPaid(int id, DateTime paidDate, int paidAmountCents) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        status: const Value('paid'),
        paidDate: Value(paidDate),
        paidAmountCents: Value(paidAmountCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark claim as closed
  Future<int> markClaimAsClosed(int id, DateTime closedDate) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        status: const Value('closed'),
        closedDate: Value(closedDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a claim
  Future<int> softDeleteClaim(int id) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      ClaimsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a claim
  Future<int> hardDeleteClaim(int id) {
    return (delete(claims)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted claim
  Future<int> restoreClaim(int id) {
    return (update(claims)..where((t) => t.id.equals(id))).write(
      const ClaimsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count claims by status
  Future<int> countClaimsByStatus(String status) async {
    final query = selectOnly(claims)
      ..addColumns([claims.id.count()])
      ..where(claims.status.equals(status))
      ..where(claims.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(claims.id.count()) ?? 0;
  }

  /// Count claims by type
  Future<int> countClaimsByType(String claimType) async {
    final query = selectOnly(claims)
      ..addColumns([claims.id.count()])
      ..where(claims.claimType.equals(claimType))
      ..where(claims.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(claims.id.count()) ?? 0;
  }

  /// Calculate total claimed amount
  Future<int> calculateTotalClaimedAmount() async {
    final allClaims = await getAllClaims();
    int total = 0;
    for (final claim in allClaims) {
      if (claim.claimedAmountCents != null) {
        total += claim.claimedAmountCents!;
      }
    }
    return total;
  }

  /// Calculate total approved amount
  Future<int> calculateTotalApprovedAmount() async {
    final allClaims = await getAllClaims();
    int total = 0;
    for (final claim in allClaims) {
      if (claim.approvedAmountCents != null) {
        total += claim.approvedAmountCents!;
      }
    }
    return total;
  }

  /// Calculate total paid amount
  Future<int> calculateTotalPaidAmount() async {
    final paidClaims = await getPaidClaims();
    int total = 0;
    for (final claim in paidClaims) {
      if (claim.paidAmountCents != null) {
        total += claim.paidAmountCents!;
      }
    }
    return total;
  }

  /// Calculate success rate (approved / total submitted)
  Future<double> calculateClaimSuccessRate() async {
    final allClaims = await getAllClaims();
    if (allClaims.isEmpty) return 0.0;
    
    final approvedCount = allClaims.where((c) => 
      c.outcome == 'approved' || c.outcome == 'partial'
    ).length;
    
    return approvedCount / allClaims.length;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get claim versions
  Future<List<ClaimEntity>> getClaimVersions(int claimId) {
    return (select(claims)
          ..where((t) => t.id.equals(claimId) | t.previousVersionId.equals(claimId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of a claim
  Future<int> createClaimVersion(int existingClaimId, ClaimsCompanion updates) async {
    final existing = await getClaimById(existingClaimId);
    if (existing == null) throw Exception('Claim not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingClaimId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(claims).insert(newVersion);
  }
}

