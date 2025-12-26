import 'domain_exceptions.dart';

/// Generic date validation rules
class DateRules {
  DateRules._();

  static const int maxFutureYears = 100;

  /// Validate start date is before or equal to end date
  static void validateDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      throw const InvalidDateException('Start date must be before or equal to end date');
    }
  }

  /// Validate date is in the future
  static void validateFutureDate(DateTime date) {
    final now = DateTime.now();
    if (date.isBefore(now)) {
      throw const InvalidDateException('Date must be in the future');
    }
  }

  /// Validate date is not too far in the future
  static void validateReasonableFutureDate(DateTime date) {
    final now = DateTime.now();
    final maxDate = DateTime(now.year + maxFutureYears, now.month, now.day);
    
    if (date.isAfter(maxDate)) {
      throw InvalidDateException('Date cannot be more than $maxFutureYears years in the future');
    }
  }

  /// Validate date is in the past
  static void validatePastDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      throw const InvalidDateException('Date must be in the past');
    }
  }

  /// Validate date is not null when required
  static void validateRequiredDate(DateTime? date, String fieldName) {
    if (date == null) {
      throw InvalidDateException('$fieldName is required');
    }
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    final difference = to.difference(from);
    return difference.inDays;
  }

  /// Get days until date from now
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    return daysBetween(now, date);
  }

  /// Get days since date from now
  static int daysSince(DateTime date) {
    final now = DateTime.now();
    return daysBetween(date, now);
  }
}

