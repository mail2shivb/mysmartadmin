import 'domain_exceptions.dart';

/// Money validation rules
///
/// All amounts are stored as integers in minor currency units (cents/pence)
class Money {
  Money._();

  /// Validate amount is not negative
  static void validateAmount(int amount) {
    if (amount < 0) {
      throw const InvalidMoneyException('Amount cannot be negative');
    }
  }

  /// Validate amount is positive (greater than zero)
  static void validatePositiveAmount(int amount) {
    if (amount <= 0) {
      throw const InvalidMoneyException('Amount must be greater than zero');
    }
  }

  /// Validate nullable amount if present
  static void validateNullableAmount(int? amount) {
    if (amount != null) {
      validateAmount(amount);
    }
  }

  /// Validate positive nullable amount if present
  static void validateNullablePositiveAmount(int? amount) {
    if (amount != null) {
      validatePositiveAmount(amount);
    }
  }

  /// Check if amount is zero
  static bool isZero(int amount) {
    return amount == 0;
  }

  /// Check if amount is positive
  static bool isPositive(int amount) {
    return amount > 0;
  }

  /// Convert to major units (e.g., cents to dollars)
  static double toMajorUnits(int amountCents) {
    return amountCents / 100.0;
  }

  /// Convert from major units to minor units
  static int toMinorUnits(double amount) {
    return (amount * 100).round();
  }
}

