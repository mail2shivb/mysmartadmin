// B11.4 STATUS: IMPLEMENTED

import '../../data/local/app_database.dart';
import 'bill_reports.dart';
import 'subscription_reports.dart';
import 'dto/monthly_cost_summary.dart';
import 'dto/active_entity_summary.dart';
import 'dto/cost_breakdown_by_category.dart';

/// Cross-entity aggregation reports service.
///
/// Read-only composition layer that aggregates data across multiple entity
/// types. Uses [BillReports] and [SubscriptionReports] for monetary
/// aggregations and [AppDatabase] directly for the documents count
/// (no DocumentReports class yet).
class AggregationReports {
  final BillReports _billReports;
  final SubscriptionReports _subscriptionReports;
  final AppDatabase _database;

  AggregationReports(
    this._billReports,
    this._subscriptionReports,
    this._database,
  );

  /// Get monthly cost summary across all commitment types
  ///
  /// Composes bills and subscriptions totals into a single summary
  Future<MonthlyCostSummary> getMonthlyCostSummary() async {
    final billsTotal = await _billReports.getMonthlyTotal();
    final subscriptionsTotal = await _subscriptionReports.getMonthlyTotal();
    final policiesTotal = 0; // PolicyReports not yet implemented
    
    final grandTotal = billsTotal + subscriptionsTotal + policiesTotal;
    
    return MonthlyCostSummary(
      billsTotal: billsTotal,
      subscriptionsTotal: subscriptionsTotal,
      policiesTotal: policiesTotal,
      grandTotal: grandTotal,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get active entity summary (counts)
  /// 
  /// Composes counts from bills, subscriptions, and reminders
  Future<ActiveEntitySummary> getActiveEntitySummary() async {
    final activeBills = await _billReports.countActiveBills();
    final activeSubscriptions = await _subscriptionReports.countActiveSubscriptions();
    final activePolicies = 0; // PolicyReports not yet implemented
    final activeDocuments = await _database.documentsDao.countAll();
    final pendingReminders = 0; // ReminderReports not yet wired up
    
    return ActiveEntitySummary(
      activeBills: activeBills,
      activeSubscriptions: activeSubscriptions,
      activePolicies: activePolicies,
      activeDocuments: activeDocuments,
      pendingReminders: pendingReminders,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get cost breakdown by category across bills and subscriptions
  /// 
  /// Composes category breakdowns from both report classes
  Future<CostBreakdownByCategory> getCostBreakdownByCategory() async {
    final billsByCategory = await _billReports.getMonthlyCostsByCategory();
    final subscriptionsByCategory = await _subscriptionReports.getMonthlyCostsByCategory();
    
    return CostBreakdownByCategory(
      billsByCategory: billsByCategory,
      subscriptionsByCategory: subscriptionsByCategory,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get total monthly commitments (bills + subscriptions)
  /// 
  /// Simple sum of monthly totals from both sources
  Future<int> getTotalMonthlyCommitments() async {
    final billsTotal = await _billReports.getMonthlyTotal();
    final subscriptionsTotal = await _subscriptionReports.getMonthlyTotal();
    
    return billsTotal + subscriptionsTotal;
  }

  /// Get total annual costs (all recurring expenses)
  /// 
  /// Calculates annual equivalent by multiplying monthly total by 12
  Future<int> getTotalAnnualCosts() async {
    final monthlyTotal = await getTotalMonthlyCommitments();
    return monthlyTotal * 12;
  }

  /// Get upcoming financial obligations (next N days)
  /// 
  /// Composes bills and subscriptions due/renewing soon
  Future<Map<String, int>> getUpcomingObligations({int daysAhead = 30}) async {
    final billsDue = await _billReports.getBillsDueSoon(daysAhead: daysAhead);
    final subscriptionsRenewing = await _subscriptionReports.getSubscriptionsRenewingSoon(
      daysAhead: daysAhead,
    );
    
    // Calculate total amounts
    int billsAmount = 0;
    for (final bill in billsDue) {
      billsAmount += bill.amountCents;
    }
    
    int subscriptionsAmount = 0;
    for (final subscription in subscriptionsRenewing) {
      subscriptionsAmount += subscription.amountCents;
    }
    
    return {
      'bills': billsAmount,
      'subscriptions': subscriptionsAmount,
      'total': billsAmount + subscriptionsAmount,
    };
  }

  /// Get entity counts by status
  /// 
  /// Returns a nested map: entityType → (status → count)
  /// Note: Requires status-based queries from individual report classes
  Future<Map<String, Map<String, int>>> getEntityCountsByStatus() async {
    // For now, return active counts only
    // Full implementation would require status breakdown methods in report classes
    final activeBills = await _billReports.countActiveBills();
    final activeSubscriptions = await _subscriptionReports.countActiveSubscriptions();
    
    return {
      'bills': {'active': activeBills},
      'subscriptions': {'active': activeSubscriptions},
    };
  }
}

