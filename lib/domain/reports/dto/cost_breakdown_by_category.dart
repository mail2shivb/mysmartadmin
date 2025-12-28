/// Cost breakdown by category DTO
/// 
/// Read-only aggregation of costs grouped by category
class CostBreakdownByCategory {
  final Map<String, int> billsByCategory;
  final Map<String, int> subscriptionsByCategory;
  final DateTime calculatedAt;

  const CostBreakdownByCategory({
    required this.billsByCategory,
    required this.subscriptionsByCategory,
    required this.calculatedAt,
  });

  /// Total across all bills
  int get totalBills =>
      billsByCategory.values.fold(0, (sum, amount) => sum + amount);

  /// Total across all subscriptions
  int get totalSubscriptions =>
      subscriptionsByCategory.values.fold(0, (sum, amount) => sum + amount);

  /// Grand total
  int get grandTotal => totalBills + totalSubscriptions;
}

