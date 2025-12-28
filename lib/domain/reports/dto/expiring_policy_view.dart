/// Expiring policy view DTO
/// 
/// Read-only view of policies expiring soon
class ExpiringPolicyView {
  final int policyId;
  final String policyName;
  final String policyType;
  final String provider;
  final DateTime renewalDate;
  final int premiumAmountCents;
  final int daysUntilExpiry;
  final bool hasReminder;

  const ExpiringPolicyView({
    required this.policyId,
    required this.policyName,
    required this.policyType,
    required this.provider,
    required this.renewalDate,
    required this.premiumAmountCents,
    required this.daysUntilExpiry,
    required this.hasReminder,
  });
}

