import 'package:flutter/material.dart';

/// All document types that can be created through the unified add-document flow.
///
/// Add a new value here when implementing a new document type. Each value
/// must also have a matching case in [SupportedDocumentTypeX] and a
/// corresponding form-fields widget.
enum SupportedDocumentType { passport, drivingLicence }

/// Display and behavioural metadata for each [SupportedDocumentType].
extension SupportedDocumentTypeX on SupportedDocumentType {
  String get defaultTitle => switch (this) {
        SupportedDocumentType.passport => 'UK Passport',
        SupportedDocumentType.drivingLicence => 'UK Driving Licence',
      };

  String get displayName => switch (this) {
        SupportedDocumentType.passport => 'Passport',
        SupportedDocumentType.drivingLicence => 'Driving Licence',
      };

  String get typeSubtitle => switch (this) {
        SupportedDocumentType.passport =>
          'Travel document with expiry tracking',
        SupportedDocumentType.drivingLicence =>
          'Photocard expiry and category records',
      };

  String get detailsSectionLabel => switch (this) {
        SupportedDocumentType.passport => 'Passport details',
        SupportedDocumentType.drivingLicence => 'Licence details',
      };

  String get expiryLabel => switch (this) {
        SupportedDocumentType.passport => 'Expiry date',
        SupportedDocumentType.drivingLicence => 'Photocard expiry date',
      };

  String get saveLabel => switch (this) {
        SupportedDocumentType.passport => 'Save passport',
        SupportedDocumentType.drivingLicence => 'Save licence',
      };

  String get reminderDialogTitle => switch (this) {
        SupportedDocumentType.passport => 'Set expiry reminder?',
        SupportedDocumentType.drivingLicence =>
          'Set photocard expiry reminder?',
      };

  String get reminderDialogBody => switch (this) {
        SupportedDocumentType.passport =>
          'We can remind you 90 days before this passport expires, '
              'so you have time to renew before any trips.',
        SupportedDocumentType.drivingLicence =>
          'We can remind you 90 days before your driving licence photocard '
              'expires, so you have time to renew without any gaps.',
      };

  IconData get icon => switch (this) {
        SupportedDocumentType.passport => Icons.book_outlined,
        SupportedDocumentType.drivingLicence => Icons.directions_car_outlined,
      };
}
