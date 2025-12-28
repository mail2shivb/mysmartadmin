/// Monthly cost summary DTO
/// 
/// Read-only aggregation of monthly costs across all commitment types
class MonthlyCostSummary {
  final int billsTotal;
  final int subscriptionsTotal;
  final int policiesTotal;
  final int grandTotal;
  final DateTime calculatedAt;

  const MonthlyCostSummary({
    required this.billsTotal,
    required this.subscriptionsTotal,
    required this.policiesTotal,
    required this.grandTotal,
    required this.calculatedAt,
  });
}

