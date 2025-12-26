import 'domain_exceptions.dart';
import 'date_rules.dart';

/// Expiry-specific validation rules
class ExpiryRules {
  ExpiryRules._();

  static const int defaultExpiryWarningDays = 30;
  static const int defaultGraceDays = 0;

  /// Validate expiry date is after issue/start date
  static void validateExpiryAfterIssue(DateTime issueDate, DateTime expiryDate) {
    if (expiryDate.isBefore(issueDate) || expiryDate.isAtSameMomentAs(issueDate)) {
      throw const InvalidExpiryException('Expiry date must be after issue date');
    }
  }

  /// Validate expiry date for new entity (must be in future)
  static void validateNewEntityExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) {
      throw const InvalidExpiryException('Expiry date must be in the future for new entities');
    }
  }

  /// Validate expiry with grace period
  static void validateExpiryWithGrace(DateTime expiryDate, int graceDays) {
    if (graceDays < 0) {
      throw const InvalidExpiryException('Grace days cannot be negative');
    }

    final now = DateTime.now();
    final graceDeadline = expiryDate.add(Duration(days: graceDays));
    
    if (now.isAfter(graceDeadline)) {
      throw InvalidExpiryException('Expiry date is beyond grace period of $graceDays days');
    }
  }

  /// Check if entity is expiring soon
  static bool isExpiringSoon(DateTime expiryDate, {int days = defaultExpiryWarningDays}) {
    if (days < 0) {
      return false;
    }

    final now = DateTime.now();
    final warningDate = now.add(Duration(days: days));
    
    return expiryDate.isBefore(warningDate) && expiryDate.isAfter(now);
  }

  /// Check if entity is expired
  static bool isExpired(DateTime expiryDate) {
    return expiryDate.isBefore(DateTime.now());
  }

  /// Check if entity is expired beyond grace period
  static bool isExpiredBeyondGrace(DateTime expiryDate, int graceDays) {
    if (graceDays < 0) {
      return isExpired(expiryDate);
    }

    final now = DateTime.now();
    final graceDeadline = expiryDate.add(Duration(days: graceDays));
    
    return now.isAfter(graceDeadline);
  }

  /// Get days until expiry
  static int daysUntilExpiry(DateTime expiryDate) {
    return DateRules.daysUntil(expiryDate);
  }

  /// Get days since expiry
  static int daysSinceExpiry(DateTime expiryDate) {
    return DateRules.daysSince(expiryDate);
  }

  /// Check if entity is within grace period
  static bool isInGracePeriod(DateTime expiryDate, int graceDays) {
    if (!isExpired(expiryDate)) {
      return false;
    }

    return !isExpiredBeyondGrace(expiryDate, graceDays);
  }

  /// Calculate renewal date (typical: expiry + 1 year)
  static DateTime calculateRenewalDate(DateTime expiryDate, {int years = 1}) {
    if (years <= 0) {
      throw const InvalidExpiryException('Renewal years must be positive');
    }

    return DateTime(
      expiryDate.year + years,
      expiryDate.month,
      expiryDate.day,
    );
  }
}

