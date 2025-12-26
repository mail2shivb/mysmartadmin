import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for insurance policy operations
/// 
/// Thin layer above policiesDao - delegates to existing DAO methods
class PoliciesRepository {
  final AppDatabase _database;

  PoliciesRepository(this._database);

  /// Add a new policy
  Future<int> addPolicy({
    required String policyName,
    required String policyNumber,
    required String policyType,
    required String provider,
    required int premiumAmountCents,
    required String premiumFrequency,
    required DateTime startDate,
    required DateTime renewalDate,
    DateTime? expiryDate,
    int? coverageAmountCents,
    bool autoRenew = false,
  }) {
    return _database.policiesDao.createPolicy(
      PoliciesCompanion.insert(
        policyName: policyName,
        policyNumber: policyNumber,
        policyType: policyType,
        provider: provider,
        premiumAmountCents: premiumAmountCents,
        premiumFrequency: premiumFrequency,
        startDate: startDate,
        renewalDate: renewalDate,
        expiryDate: Value(expiryDate),
        coverageAmountCents: Value(coverageAmountCents),
        autoRenew: Value(autoRenew),
      ),
    );
  }

  /// Stream active policies
  Stream<List<PolicyEntity>> watchActivePolicies() {
    return _database.policiesDao.watchActivePolicies();
  }

  /// Get a single policy by ID
  Future<PolicyEntity?> getPolicyById(int id) {
    return _database.policiesDao.getPolicyById(id);
  }

  /// Get policies expiring within a date range
  Future<List<PolicyEntity>> getPoliciesExpiringBetween(
    DateTime from,
    DateTime to,
  ) {
    return _database.policiesDao.getPoliciesExpiringBetween(from, to);
  }

  /// Soft delete a policy (can be restored later)
  Future<int> softDeletePolicy(int id) {
    return _database.policiesDao.softDeletePolicy(id);
  }
}

