// B12 STATUS: IMPLEMENTED

import '../../domain/reports/reports_repository.dart';
import '../../domain/reports/dto/monthly_cost_summary.dart';
import '../../domain/reports/dto/active_entity_summary.dart';
import '../../domain/reports/dto/cost_breakdown_by_category.dart';

/// Dashboard ViewModel
///
/// Thin adapter for dashboard UI to fetch aggregated financial data.
/// Calls ReportsRepository and returns DTOs directly.
/// Contains NO business logic, NO caching, NO mutation.
class DashboardViewModel {
  final ReportsRepository _repository;

  DashboardViewModel(this._repository);

  /// Load monthly cost summary across all commitment types
  ///
  /// Returns aggregated costs for bills, subscriptions, and policies.
  Future<MonthlyCostSummary> loadMonthlyCostSummary() async {
    return await _repository.getMonthlyCostSummary();
  }

  /// Load active entity summary (counts)
  ///
  /// Returns counts of active bills, subscriptions, policies, and reminders.
  Future<ActiveEntitySummary> loadActiveEntitiesSummary() async {
    return await _repository.getActiveEntitySummary();
  }

  /// Load cost breakdown by category
  ///
  /// Returns bills and subscriptions grouped by category with monthly totals.
  Future<CostBreakdownByCategory> loadCostBreakdown() async {
    return await _repository.getCostBreakdownByCategory();
  }

  /// Load total monthly commitments
  ///
  /// Returns sum of all recurring monthly costs (bills + subscriptions).
  Future<int> loadTotalMonthlyCommitments() async {
    return await _repository.getTotalMonthlyCommitments();
  }

  /// Load total annual costs
  ///
  /// Returns total annual cost projection (monthly * 12).
  Future<int> loadTotalAnnualCosts() async {
    return await _repository.getTotalAnnualCosts();
  }

  /// Load upcoming obligations
  ///
  /// Returns bills and subscriptions due within the next N days.
  /// [daysAhead] defaults to 30 days.
  Future<Map<String, int>> loadUpcomingObligations({int daysAhead = 30}) async {
    return await _repository.getUpcomingObligations(daysAhead: daysAhead);
  }

  /// Load entity counts by status
  ///
  /// Returns nested map: entityType → (status → count)
  Future<Map<String, Map<String, int>>> loadEntityCountsByStatus() async {
    return await _repository.getEntityCountsByStatus();
  }
}

