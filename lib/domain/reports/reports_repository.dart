// B11.5 STATUS: IMPLEMENTED

import '../../data/local/app_database.dart';
import 'bill_reports.dart';
import 'subscription_reports.dart';
import 'policy_reports.dart';
import 'reminder_reports.dart';
import 'aggregation_reports.dart';
import 'dto/monthly_cost_summary.dart';
import 'dto/active_entity_summary.dart';
import 'dto/cost_breakdown_by_category.dart';
import 'dto/upcoming_reminder_view.dart';
import 'dto/expiring_policy_view.dart';

/// Main reports repository
/// 
/// Single read-side boundary for all domain queries
/// Acts as a thin façade over specialized report classes
/// Domain layer only - no UI dependencies, no business logic
class ReportsRepository {
  final AppDatabase _database;

  late final BillReports bills;
  late final SubscriptionReports subscriptions;
  late final PolicyReports policies;
  late final ReminderReports reminders;
  late final AggregationReports aggregations;

  ReportsRepository(this._database) {
    bills = BillReports(_database);
    subscriptions = SubscriptionReports(_database);
    policies = PolicyReports(_database);
    reminders = ReminderReports(_database);
    aggregations = AggregationReports(bills, subscriptions, _database);
  }

  // ============================================================
  // AGGREGATION QUERIES
  // ============================================================

  /// Get monthly cost summary across all commitment types
  Future<MonthlyCostSummary> getMonthlyCostSummary() {
    return aggregations.getMonthlyCostSummary();
  }

  /// Get active entity summary (counts)
  Future<ActiveEntitySummary> getActiveEntitySummary() {
    return aggregations.getActiveEntitySummary();
  }

  /// Get cost breakdown by category
  Future<CostBreakdownByCategory> getCostBreakdownByCategory() {
    return aggregations.getCostBreakdownByCategory();
  }

  /// Get total monthly commitments (bills + subscriptions)
  Future<int> getTotalMonthlyCommitments() {
    return aggregations.getTotalMonthlyCommitments();
  }

  /// Get total annual costs
  Future<int> getTotalAnnualCosts() {
    return aggregations.getTotalAnnualCosts();
  }

  /// Get upcoming obligations (bills + subscriptions due soon)
  Future<Map<String, int>> getUpcomingObligations({int daysAhead = 30}) {
    return aggregations.getUpcomingObligations(daysAhead: daysAhead);
  }

  /// Get entity counts by status
  Future<Map<String, Map<String, int>>> getEntityCountsByStatus() {
    return aggregations.getEntityCountsByStatus();
  }

  // ============================================================
  // BILL QUERIES
  // ============================================================

  /// Get total monthly bill costs
  Future<int> getBillsMonthlyTotal() {
    return bills.getMonthlyTotal();
  }

  /// Get bills by category with totals
  Future<Map<String, int>> getBillsMonthlyCostsByCategory() {
    return bills.getMonthlyCostsByCategory();
  }

  /// Get bills due within next N days
  Future<List<BillEntity>> getBillsDueSoon({int daysAhead = 7}) {
    return bills.getBillsDueSoon(daysAhead: daysAhead);
  }

  /// Get overdue bills
  Future<List<BillEntity>> getOverdueBills() {
    return bills.getOverdueBills();
  }

  /// Count active bills
  Future<int> countActiveBills() {
    return bills.countActiveBills();
  }

  /// Get highest cost bills
  Future<List<BillEntity>> getHighestCostBills({int limit = 5}) {
    return bills.getHighestCostBills(limit: limit);
  }

  /// Get bills grouped by provider
  Future<Map<String, List<BillEntity>>> getBillsByProvider() {
    return bills.getBillsByProvider();
  }

  // ============================================================
  // SUBSCRIPTION QUERIES
  // ============================================================

  /// Get total monthly subscription costs
  Future<int> getSubscriptionsMonthlyTotal() {
    return subscriptions.getMonthlyTotal();
  }

  /// Get subscriptions by category with totals
  Future<Map<String, int>> getSubscriptionsMonthlyCostsByCategory() {
    return subscriptions.getMonthlyCostsByCategory();
  }

  /// Get subscriptions renewing within next N days
  Future<List<SubscriptionEntity>> getSubscriptionsRenewingSoon({int daysAhead = 7}) {
    return subscriptions.getSubscriptionsRenewingSoon(daysAhead: daysAhead);
  }

  /// Get trials ending within next N days
  Future<List<SubscriptionEntity>> getTrialsEndingSoon({int daysAhead = 7}) {
    return subscriptions.getTrialsEndingSoon(daysAhead: daysAhead);
  }

  /// Count active subscriptions
  Future<int> countActiveSubscriptions() {
    return subscriptions.countActiveSubscriptions();
  }

  /// Get highest cost subscriptions
  Future<List<SubscriptionEntity>> getHighestCostSubscriptions({int limit = 5}) {
    return subscriptions.getHighestCostSubscriptions(limit: limit);
  }

  /// Get subscriptions grouped by provider
  Future<Map<String, List<SubscriptionEntity>>> getSubscriptionsByProvider() {
    return subscriptions.getSubscriptionsByProvider();
  }

  /// Get unused subscriptions (no last usage date within N days)
  Future<List<SubscriptionEntity>> getUnusedSubscriptions({int days = 90}) {
    return subscriptions.getUnusedSubscriptions(days: days);
  }

  // ============================================================
  // POLICY QUERIES
  // ============================================================

  /// Get total monthly policy costs
  Future<int> getPoliciesMonthlyTotal() {
    return policies.getMonthlyTotal();
  }

  /// Get total annual policy costs
  Future<int> getPoliciesAnnualTotal() {
    return policies.getAnnualTotal();
  }

  /// Get annual costs grouped by policy type
  Future<Map<String, int>> getAnnualCostsByPolicyType() {
    return policies.getAnnualCostsByType();
  }

  /// Get policies expiring within next N days
  Future<List<ExpiringPolicyView>> getPoliciesExpiringSoon({int daysAhead = 30}) {
    return policies.getPoliciesExpiringSoon(daysAhead: daysAhead);
  }

  /// Get policies renewing within next N days
  Future<List<PolicyEntity>> getPoliciesRenewingSoon({int daysAhead = 30}) {
    return policies.getPoliciesRenewingSoon(daysAhead: daysAhead);
  }

  /// Count active policies
  Future<int> countActivePolicies() {
    return policies.countActivePolicies();
  }

  /// Get total coverage amount across all policies
  Future<int> getTotalCoverageAmount() {
    return policies.getTotalCoverageAmount();
  }

  /// Get policies grouped by provider
  Future<Map<String, List<PolicyEntity>>> getPoliciesByProvider() {
    return policies.getPoliciesByProvider();
  }

  /// Get policies grouped by type
  Future<Map<String, List<PolicyEntity>>> getPoliciesByType() {
    return policies.getPoliciesByType();
  }

  // ============================================================
  // REMINDER QUERIES
  // ============================================================

  /// Get reminders due between from and to dates
  Future<List<UpcomingReminderView>> getUpcomingReminders({
    required DateTime from,
    required DateTime to,
  }) {
    return reminders.upcoming(from: from, to: to);
  }

  /// Get reminders due within next N days
  Future<List<UpcomingReminderView>> getRemindersDueSoon({int daysAhead = 7}) {
    return reminders.getRemindersDueSoon(daysAhead: daysAhead);
  }

  /// Get overdue reminders
  Future<List<ReminderEntity>> getOverdueReminders() {
    return reminders.getOverdueReminders();
  }

  /// Get reminders grouped by entity kind
  Future<Map<String, List<ReminderEntity>>> getRemindersByEntityType() {
    return reminders.getRemindersByEntityKind();
  }

  /// Count pending reminders
  Future<int> countPendingReminders() {
    return reminders.countPendingReminders();
  }

  /// Count overdue reminders
  Future<int> countOverdueReminders() {
    return reminders.countOverdueReminders();
  }

  /// Get reminder counts grouped by state
  Future<Map<String, int>> getReminderCountsByStatus() {
    return reminders.getReminderCountsByState();
  }

  /// Get reminders for a specific entity
  Future<List<ReminderEntity>> getRemindersForEntity({
    required String sourceEntityKind,
    required int sourceEntityId,
  }) {
    return reminders.getRemindersForEntity(
      sourceEntityKind: sourceEntityKind,
      sourceEntityId: sourceEntityId,
    );
  }

  // ============================================================
  // LEGACY/CONVENIENCE METHODS (Quick Access)
  // ============================================================

  /// Quick access to monthly total across all commitments
  /// 
  /// Delegates to aggregations.getTotalMonthlyCommitments()
  Future<int> getMonthlyTotal() {
    return aggregations.getTotalMonthlyCommitments();
  }

  /// Quick access to pending reminder count
  /// 
  /// Delegates to reminders.countPendingReminders()
  Future<int> getPendingReminderCount() {
    return reminders.countPendingReminders();
  }

  /// Quick access to active entity counts
  /// 
  /// Delegates to aggregations.getEntityCountsByStatus()
  /// Returns only 'active' counts as a flat map
  Future<Map<String, int>> getActiveEntityCounts() async {
    final statusCounts = await aggregations.getEntityCountsByStatus();
    return statusCounts.map((entityType, statusMap) {
      return MapEntry(entityType, statusMap['active'] ?? 0);
    });
  }
}

