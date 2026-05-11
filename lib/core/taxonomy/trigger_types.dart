/// Canonical reminder trigger-type string IDs.
///
/// These values are stored in [ReminderEntity.triggerTypeId] and must match
/// the strings written by [AutoGenerateReminderUseCase] and understood by
/// [RemindersDao].
abstract final class TriggerTypeIds {
  static const expiryDate = 'expiry_date';
  static const renewalDate = 'renewal_date';
  static const reviewDate = 'review_date';
  static const paymentDueDate = 'payment_due_date';
  static const serviceDueDate = 'service_due_date';
  static const contractEndDate = 'contract_end_date';
  static const trialEndDate = 'trial_end_date';
  static const statementAvailableDate = 'statement_available_date';
}
