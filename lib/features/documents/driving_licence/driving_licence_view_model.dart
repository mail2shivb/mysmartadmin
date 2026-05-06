import 'dart:convert';

import '../../../data/local/app_database.dart';
import '../../../domain/usecases/documents/add_document_usecase.dart';
import '../../../domain/usecases/reminders/auto_generate_reminder_usecase.dart';

// ── Expiry status (reuses same semantics as PassportExpiryStatus) ─────────────

enum DrivingLicenceExpiryStatus { valid, expiringSoon, expired, unknown }

// ── Driving licence document model ───────────────────────────────────────────

/// Thin wrapper around [DocumentEntity] that surfaces Zone-B driving licence fields.
///
/// Zone-B keys used:
///   licence_number, categories
class DrivingLicenceDoc {
  final DocumentEntity document;
  final String? licenceNumber;

  /// Comma-separated licence category codes, e.g. "B, BE, AM".
  final String? categories;

  const DrivingLicenceDoc({
    required this.document,
    this.licenceNumber,
    this.categories,
  });

  factory DrivingLicenceDoc.fromEntity(DocumentEntity e) {
    var z = <String, dynamic>{};
    final raw = e.extraFieldsJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        z = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        // Malformed Zone-B JSON: fall through with empty map.
      }
    }
    return DrivingLicenceDoc(
      document: e,
      licenceNumber: z['licence_number'] as String?,
      categories: z['categories'] as String?,
    );
  }

  DrivingLicenceExpiryStatus get expiryStatus {
    final expiry = document.expiryDate;
    if (expiry == null) return DrivingLicenceExpiryStatus.unknown;
    final now = DateTime.now();
    if (expiry.isBefore(now)) return DrivingLicenceExpiryStatus.expired;
    if (expiry.isBefore(now.add(const Duration(days: 90)))) {
      return DrivingLicenceExpiryStatus.expiringSoon;
    }
    return DrivingLicenceExpiryStatus.valid;
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class DrivingLicenceViewModel {
  final AppDatabase _database;

  DrivingLicenceViewModel(this._database);

  /// Load all documents classified as `driving_licence`, sorted expiry-first.
  Future<List<DrivingLicenceDoc>> loadLicences() async {
    final docs =
        await _database.documentsDao.getByDocumentType('driving_licence');
    final list = docs.map(DrivingLicenceDoc.fromEntity).toList()
      ..sort((a, b) {
        final ae = a.document.expiryDate;
        final be = b.document.expiryDate;
        if (ae == null && be == null) return 0;
        if (ae == null) return 1; // nulls last
        if (be == null) return -1;
        return ae.compareTo(be);
      });
    return list;
  }

  /// Insert and classify a driving licence document in a single transaction.
  ///
  /// Both steps are atomic so a crash between insert and classify cannot
  /// leave the record permanently unclassified.
  Future<int> saveLicence({
    required String title,
    required String licenceNumber,
    required DateTime issueDate,
    required DateTime expiryDate,
    String? categories,
  }) {
    final zoneB = <String, String>{
      'licence_number': licenceNumber.trim(),
      if (categories != null && categories.trim().isNotEmpty)
        'categories': categories.trim(),
    };

    return _database.transaction(() async {
      final documentId = await AddDocumentUseCase(_database)(
        title: title.trim(),
        issueDate: issueDate,
        expiryDate: expiryDate,
        extraFieldsJson: jsonEncode(zoneB),
        source: 'manual',
      );

      await _database.documentsDao.classify(
        id: documentId,
        documentTypeId: 'driving_licence',
        categoryId: 'personal_identity',
        domainId: 'identity_legal',
        taxonomyVersion: 1,
      );

      return documentId;
    });
  }

  /// Create a photocard expiry reminder 90 days before [expiryDate].
  ///
  /// Returns null if skipped (duplicate or fire date already in the past).
  Future<int?> createExpiryReminder(int documentId, DateTime expiryDate) {
    return AutoGenerateReminderUseCase(_database)(
      documentId: documentId,
      triggerTypeId: 'expiry_date',
      targetDate: expiryDate,
      leadInDays: 90,
      userNote:
          'Driving licence photocard expires soon — renew to keep it valid.',
    );
  }
}
