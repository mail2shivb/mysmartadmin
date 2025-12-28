/// Active entity summary DTO
/// 
/// Read-only count of active entities by type
class ActiveEntitySummary {
  final int activeBills;
  final int activeSubscriptions;
  final int activePolicies;
  final int activeDocuments;
  final int pendingReminders;
  final DateTime calculatedAt;

  const ActiveEntitySummary({
    required this.activeBills,
    required this.activeSubscriptions,
    required this.activePolicies,
    required this.activeDocuments,
    required this.pendingReminders,
    required this.calculatedAt,
  });
}

