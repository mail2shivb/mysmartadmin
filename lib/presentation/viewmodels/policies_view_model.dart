// B12 STATUS: IMPLEMENTED

import '../../domain/reports/reports_repository.dart';
import '../../domain/reports/dto/expiring_policy_view.dart';
import '../../data/local/app_database.dart';

/// Policies ViewModel
///
/// Thin adapter for policies UI to fetch insurance policy data.
/// Calls ReportsRepository and returns DTOs/entities directly.
/// Contains NO business logic, NO caching, NO mutation.
class PoliciesViewModel {
  final ReportsRepository _repository;

  PoliciesViewModel(this._repository);

  /// Load total monthly policy costs
  ///
  /// Returns sum of all active policy premiums normalized to monthly amounts.
  Future<int> loadPoliciesMonthlyTotal() async {
    return await _repository.getPoliciesMonthlyTotal();
  }

  /// Load total annual policy costs
  ///
  /// Returns sum of all active policy premiums as annual amounts.
  Future<int> loadPoliciesAnnualTotal() async {
    return await _repository.getPoliciesAnnualTotal();
  }

  /// Load annual costs grouped by policy type
  ///
  /// Returns map: policyType → annual cost
  Future<Map<String, int>> loadAnnualCostsByPolicyType() async {
    return await _repository.getAnnualCostsByPolicyType();
  }

  /// Load policies expiring within next N days
  ///
  /// Returns policies approaching expiry with metadata.
  /// [daysAhead] defaults to 30 days
  Future<List<ExpiringPolicyView>> loadPoliciesExpiringSoon({
    int daysAhead = 30,
  }) async {
    return await _repository.getPoliciesExpiringSoon(daysAhead: daysAhead);
  }

  /// Load policies renewing within next N days
  ///
  /// Returns policies approaching renewal date.
  /// [daysAhead] defaults to 30 days
  Future<List<PolicyEntity>> loadPoliciesRenewingSoon({
    int daysAhead = 30,
  }) async {
    return await _repository.getPoliciesRenewingSoon(daysAhead: daysAhead);
  }

  /// Count active policies
  ///
  /// Returns total count of active (not deleted) policies.
  Future<int> countActivePolicies() async {
    return await _repository.countActivePolicies();
  }

  /// Load total coverage amount
  ///
  /// Returns sum of coverage amounts across all active policies.
  Future<int> loadTotalCoverageAmount() async {
    return await _repository.getTotalCoverageAmount();
  }

  /// Load policies grouped by provider
  ///
  /// Returns map: provider → list of policies
  Future<Map<String, List<PolicyEntity>>> loadPoliciesByProvider() async {
    return await _repository.getPoliciesByProvider();
  }

  /// Load policies grouped by type
  ///
  /// Returns map: policyType → list of policies
  Future<Map<String, List<PolicyEntity>>> loadPoliciesByType() async {
    return await _repository.getPoliciesByType();
  }
}

