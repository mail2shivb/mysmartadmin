import 'domain_exceptions.dart';
import 'money.dart';
import 'date_rules.dart';
import 'expiry_rules.dart';
import 'versioning_rules.dart';

/// Entity-specific validation rules
class EntityValidators {
  EntityValidators._();

  /// Validate Bill entity
  static void validateBill({
    required String name,
    required String category,
    required int amountCents,
    required bool isRecurring,
    String? frequency,
    DateTime? nextDueDate,
    int version = 1,
    int? previousVersionId,
  }) {
    if (name.trim().isEmpty) {
      throw const DomainValidationException('Bill name cannot be empty');
    }

    if (category.trim().isEmpty) {
      throw const DomainValidationException('Bill category cannot be empty');
    }

    Money.validatePositiveAmount(amountCents);

    if (isRecurring) {
      if (frequency == null || frequency.trim().isEmpty) {
        throw const DomainValidationException('Frequency is required for recurring bills');
      }

      if (nextDueDate == null) {
        throw const DomainValidationException('Next due date is required for recurring bills');
      }
    }

    if (nextDueDate != null) {
      DateRules.validateFutureDate(nextDueDate);
      DateRules.validateReasonableFutureDate(nextDueDate);
    }

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }

  /// Validate Subscription entity
  static void validateSubscription({
    required String name,
    required String category,
    required int amountCents,
    required String billingFrequency,
    required DateTime startDate,
    required DateTime renewalDate,
    bool isTrial = false,
    DateTime? trialEndDate,
    DateTime? cancellationDate,
    int version = 1,
    int? previousVersionId,
  }) {
    if (name.trim().isEmpty) {
      throw const DomainValidationException('Subscription name cannot be empty');
    }

    if (category.trim().isEmpty) {
      throw const DomainValidationException('Subscription category cannot be empty');
    }

    Money.validatePositiveAmount(amountCents);

    if (billingFrequency.trim().isEmpty) {
      throw const DomainValidationException('Billing frequency cannot be empty');
    }

    if (!['monthly', 'annual'].contains(billingFrequency.toLowerCase())) {
      throw const DomainValidationException('Billing frequency must be monthly or annual');
    }

    DateRules.validateDateRange(startDate, renewalDate);
    DateRules.validateReasonableFutureDate(renewalDate);

    if (isTrial) {
      if (trialEndDate == null) {
        throw const DomainValidationException('Trial end date is required for trial subscriptions');
      }
      DateRules.validateDateRange(startDate, trialEndDate);
    }

    if (cancellationDate != null) {
      DateRules.validateDateRange(startDate, cancellationDate);
    }

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }

  /// Validate Policy entity
  static void validatePolicy({
    required String policyName,
    required String policyNumber,
    required String policyType,
    required int premiumAmountCents,
    required DateTime renewalDate,
    DateTime? startDate,
    DateTime? expiryDate,
    int? coverageAmountCents,
    int version = 1,
    int? previousVersionId,
  }) {
    if (policyName.trim().isEmpty) {
      throw const DomainValidationException('Policy name cannot be empty');
    }

    if (policyNumber.trim().isEmpty) {
      throw const DomainValidationException('Policy number cannot be empty');
    }

    if (policyType.trim().isEmpty) {
      throw const DomainValidationException('Policy type cannot be empty');
    }

    Money.validatePositiveAmount(premiumAmountCents);
    Money.validateNullablePositiveAmount(coverageAmountCents);

    DateRules.validateFutureDate(renewalDate);
    DateRules.validateReasonableFutureDate(renewalDate);

    if (startDate != null && expiryDate != null) {
      DateRules.validateDateRange(startDate, expiryDate);
      ExpiryRules.validateExpiryAfterIssue(startDate, expiryDate);
    }

    if (expiryDate != null) {
      ExpiryRules.validateNewEntityExpiry(expiryDate);
    }

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }

  /// Validate Document entity
  static void validateDocument({
    required String title,
    required String documentType,
    required String category,
    DateTime? documentDate,
    DateTime? expiryDate,
    DateTime? reminderDate,
    int? fileSizeBytes,
    int version = 1,
    int? previousVersionId,
  }) {
    if (title.trim().isEmpty) {
      throw const DomainValidationException('Document title cannot be empty');
    }

    if (documentType.trim().isEmpty) {
      throw const DomainValidationException('Document type cannot be empty');
    }

    if (category.trim().isEmpty) {
      throw const DomainValidationException('Document category cannot be empty');
    }

    if (fileSizeBytes != null && fileSizeBytes < 0) {
      throw const DomainValidationException('File size cannot be negative');
    }

    if (documentDate != null && expiryDate != null) {
      ExpiryRules.validateExpiryAfterIssue(documentDate, expiryDate);
    }

    if (reminderDate != null) {
      DateRules.validateFutureDate(reminderDate);
    }

    if (expiryDate != null) {
      DateRules.validateReasonableFutureDate(expiryDate);
    }

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }

  /// Validate Reminder entity
  static void validateReminder({
    required String title,
    required DateTime reminderDate,
    required String reminderType,
    DateTime? snoozeUntil,
  }) {
    if (title.trim().isEmpty) {
      throw const DomainValidationException('Reminder title cannot be empty');
    }

    if (reminderType.trim().isEmpty) {
      throw const DomainValidationException('Reminder type cannot be empty');
    }

    DateRules.validateFutureDate(reminderDate);
    DateRules.validateReasonableFutureDate(reminderDate);

    if (snoozeUntil != null) {
      DateRules.validateFutureDate(snoozeUntil);
      
      if (snoozeUntil.isBefore(reminderDate)) {
        throw const InvalidDateException('Snooze date must be after reminder date');
      }
    }
  }

  /// Validate Property entity
  static void validateProperty({
    required String addressLine1,
    required String city,
    required String postcode,
    required String propertyType,
    required String ownership,
    int? currentValueCents,
    int? purchasePriceCents,
    int? mortgageBalanceCents,
    DateTime? purchaseDate,
    DateTime? moveInDate,
    DateTime? leaseEndDate,
    int version = 1,
    int? previousVersionId,
  }) {
    if (addressLine1.trim().isEmpty) {
      throw const DomainValidationException('Address line 1 cannot be empty');
    }

    if (city.trim().isEmpty) {
      throw const DomainValidationException('City cannot be empty');
    }

    if (postcode.trim().isEmpty) {
      throw const DomainValidationException('Postcode cannot be empty');
    }

    if (propertyType.trim().isEmpty) {
      throw const DomainValidationException('Property type cannot be empty');
    }

    if (ownership.trim().isEmpty) {
      throw const DomainValidationException('Ownership cannot be empty');
    }

    Money.validateNullableAmount(currentValueCents);
    Money.validateNullableAmount(purchasePriceCents);
    Money.validateNullableAmount(mortgageBalanceCents);

    if (purchaseDate != null && moveInDate != null) {
      DateRules.validateDateRange(purchaseDate, moveInDate);
    }

    if (leaseEndDate != null) {
      DateRules.validateFutureDate(leaseEndDate);
    }

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }

  /// Validate Vehicle entity
  static void validateVehicle({
    required String make,
    required String model,
    required String vehicleType,
    required String ownership,
    int? currentValueCents,
    int? purchasePriceCents,
    int? financeBalanceCents,
    int? currentMileage,
    DateTime? purchaseDate,
    DateTime? motExpiryDate,
    DateTime? taxExpiryDate,
    DateTime? insuranceExpiryDate,
    int version = 1,
    int? previousVersionId,
  }) {
    if (make.trim().isEmpty) {
      throw const DomainValidationException('Vehicle make cannot be empty');
    }

    if (model.trim().isEmpty) {
      throw const DomainValidationException('Vehicle model cannot be empty');
    }

    if (vehicleType.trim().isEmpty) {
      throw const DomainValidationException('Vehicle type cannot be empty');
    }

    if (ownership.trim().isEmpty) {
      throw const DomainValidationException('Ownership cannot be empty');
    }

    Money.validateNullableAmount(currentValueCents);
    Money.validateNullableAmount(purchasePriceCents);
    Money.validateNullableAmount(financeBalanceCents);

    if (currentMileage != null && currentMileage < 0) {
      throw const DomainValidationException('Current mileage cannot be negative');
    }

    if (motExpiryDate != null) {
      DateRules.validateReasonableFutureDate(motExpiryDate);
    }

    if (taxExpiryDate != null) {
      DateRules.validateReasonableFutureDate(taxExpiryDate);
    }

    if (insuranceExpiryDate != null) {
      DateRules.validateFutureDate(insuranceExpiryDate);
      DateRules.validateReasonableFutureDate(insuranceExpiryDate);
    }

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }

  /// Validate Account entity
  static void validateAccount({
    required String accountName,
    required String accountType,
    required String provider,
    int currentBalanceCents = 0,
    int? availableBalanceCents,
    int? creditLimitCents,
    int? outstandingBalanceCents,
    int version = 1,
    int? previousVersionId,
  }) {
    if (accountName.trim().isEmpty) {
      throw const DomainValidationException('Account name cannot be empty');
    }

    if (accountType.trim().isEmpty) {
      throw const DomainValidationException('Account type cannot be empty');
    }

    if (provider.trim().isEmpty) {
      throw const DomainValidationException('Provider cannot be empty');
    }

    Money.validateNullableAmount(availableBalanceCents);
    Money.validateNullablePositiveAmount(creditLimitCents);
    Money.validateNullableAmount(outstandingBalanceCents);

    VersioningRules.validateVersionNumber(version);
    VersioningRules.validatePreviousVersionReference(version, previousVersionId);
  }
}

