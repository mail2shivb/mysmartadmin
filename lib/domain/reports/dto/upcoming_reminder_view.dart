/// Upcoming reminder view DTO.
///
/// Read-only view of a reminder within a timeframe, aligned to the B8 schema.
class UpcomingReminderView {
  final int reminderId;
  final String sourceEntityKind;
  final int sourceEntityId;
  final String triggerTypeId;
  final DateTime firesAt;
  final DateTime targetDate;
  final String state;
  final int daysUntilDue;
  final String? userNote;

  const UpcomingReminderView({
    required this.reminderId,
    required this.sourceEntityKind,
    required this.sourceEntityId,
    required this.triggerTypeId,
    required this.firesAt,
    required this.targetDate,
    required this.state,
    required this.daysUntilDue,
    this.userNote,
  });
}
