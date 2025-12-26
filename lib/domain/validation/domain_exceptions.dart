/// Base exception for domain validation failures
class DomainValidationException implements Exception {
  final String message;

  const DomainValidationException(this.message);

  @override
  String toString() => message;
}

/// Exception for invalid money/amount values
class InvalidMoneyException extends DomainValidationException {
  const InvalidMoneyException(super.message);
}

/// Exception for invalid date values or relationships
class InvalidDateException extends DomainValidationException {
  const InvalidDateException(super.message);
}

/// Exception for invalid expiry date logic
class InvalidExpiryException extends DomainValidationException {
  const InvalidExpiryException(super.message);
}

/// Exception for invalid versioning logic
class InvalidVersioningException extends DomainValidationException {
  const InvalidVersioningException(super.message);
}

