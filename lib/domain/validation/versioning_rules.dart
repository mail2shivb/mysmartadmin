import 'domain_exceptions.dart';

/// Versioning validation rules
class VersioningRules {
  VersioningRules._();

  static const int initialVersion = 1;

  /// Validate version number is valid
  static void validateVersionNumber(int version) {
    if (version < initialVersion) {
      throw InvalidVersioningException('Version must be at least $initialVersion');
    }
  }

  /// Validate version increment is exactly +1
  static void validateVersionIncrement(int oldVersion, int newVersion) {
    validateVersionNumber(oldVersion);
    validateVersionNumber(newVersion);

    if (newVersion != oldVersion + 1) {
      throw const InvalidVersioningException('Version must increment by exactly 1');
    }
  }

  /// Validate initial version
  static void validateInitialVersion(int version) {
    if (version != initialVersion) {
      throw InvalidVersioningException('Initial version must be $initialVersion');
    }
  }

  /// Validate version has previous reference when required
  static void validatePreviousVersionReference(
    int version,
    int? previousVersionId,
  ) {
    validateVersionNumber(version);

    if (version > initialVersion && previousVersionId == null) {
      throw const InvalidVersioningException(
        'Version greater than 1 must have previousVersionId',
      );
    }

    if (version == initialVersion && previousVersionId != null) {
      throw const InvalidVersioningException(
        'Initial version cannot have previousVersionId',
      );
    }
  }

  /// Validate previous version ID is valid
  static void validatePreviousVersionId(int? previousVersionId) {
    if (previousVersionId != null && previousVersionId <= 0) {
      throw const InvalidVersioningException('previousVersionId must be a valid positive ID');
    }
  }

  /// Check if version is initial
  static bool isInitialVersion(int version) {
    return version == initialVersion;
  }

  /// Calculate next version number
  static int nextVersion(int currentVersion) {
    validateVersionNumber(currentVersion);
    return currentVersion + 1;
  }

  /// Check if version is valid for update
  static bool canCreateNewVersion(int currentVersion) {
    return currentVersion >= initialVersion;
  }
}

