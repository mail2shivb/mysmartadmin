/// Upcoming reminder view DTO
/// 
/// Read-only view of reminders due within a timeframe
class UpcomingReminderView {
  final int reminderId;
  final String entityType;
  final int entityId;
  final String title;
  final DateTime reminderDate;
  final String reminderType;
  final String status;
  final int daysUntilDue;

  const UpcomingReminderView({
    required this.reminderId,
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.reminderDate,
    required this.reminderType,
    required this.status,
    required this.daysUntilDue,
  });
}

