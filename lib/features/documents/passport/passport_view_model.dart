import 'dart:convert';

import '../../../data/local/app_database.dart';
import '../../../domain/usecases/documents/add_document_usecase.dart';
import '../../../domain/usecases/reminders/auto_generate_reminder_usecase.dart';

// ── Expiry status ──────────────────────────────────────────────────────────────

enum PassportExpiryStatus { valid, expiringSoon, expired, unknown }

// ── Passport document model ───────────────────────────────────────────────────

/// Thin wrapper around [DocumentEntity] that surfaces Zone-B passport fields.
///
/// Zone-B keys used:
///   passport_number, nationality, surname, given_names
class PassportDoc {
  final DocumentEntity document;
  final String? passportNumber;
  final String? nationality;
  final String? surname;
  final String? givenNames;

  const PassportDoc({
    required this.document,
    this.passportNumber,
    this.nationality,
    this.surname,
    this.givenNames,
  });

  factory PassportDoc.fromEntity(DocumentEntity e) {
    var z = <String, dynamic>{};
    final raw = e.extraFieldsJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        z = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        // Malformed JSON: fall through with empty map.
      }
    }
    return PassportDoc(
      document: e,
      passportNumber: z['passport_number'] as String?,
      nationality: z['nationality'] as String?,
      surname: z['surname'] as String?,
      givenNames: z['given_names'] as String?,
    );
  }

  PassportExpiryStatus get expiryStatus {
    final expiry = document.expiryDate;
    if (expiry == null) return PassportExpiryStatus.unknown;
    final now = DateTime.now();
    if (expiry.isBefore(now)) return PassportExpiryStatus.expired;
    if (expiry.isBefore(now.add(const Duration(days: 90)))) {
      return PassportExpiryStatus.expiringSoon;
    }
    return PassportExpiryStatus.valid;
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class PassportViewModel {
  final AppDatabase _database;

  PassportViewModel(this._database);

  /// Load all documents classified as `passport`, sorted by expiry (soonest first).
  Future<List<PassportDoc>> loadPassports() async {
    final docs = await _database.documentsDao.getByDocumentType('passport');
    final list = docs.map(PassportDoc.fromEntity).toList()
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

  /// Insert a new passport document and immediately classify it.
  ///
  /// Both steps run inside a single transaction so the record is never left
  /// unclassified if the process is interrupted between insert and classify.
  Future<int> savePassport({
    required String title,
    required String passportNumber,
    required DateTime issueDate,
    required DateTime expiryDate,
    String? nationality,
    String? surname,
    String? givenNames,
  }) {
    // Build the Zone-B JSON object. Only include optional fields when non-empty.
    final zoneB = <String, String>{
      'passport_number': passportNumber.trim(),
      if (nationality != null && nationality.trim().isNotEmpty)
        'nationality': nationality.trim(),
      if (surname != null && surname.trim().isNotEmpty)
        'surname': surname.trim(),
      if (givenNames != null && givenNames.trim().isNotEmpty)
        'given_names': givenNames.trim(),
    };

    return _database.transaction(() async {
      final documentId = await AddDocumentUseCase(_database)(
        title: title.trim(),
        issueDate: issueDate,
        expiryDate: expiryDate,
        extraFieldsJson: jsonEncode(zoneB),
        source: 'manual',
      );

      // Classify immediately — document leaves classification_pending state.
      await _database.documentsDao.classify(
        id: documentId,
        documentTypeId: 'passport',
        categoryId: 'personal_identity',
        domainId: 'identity_legal',
        taxonomyVersion: 1,
      );

      return documentId;
    });
  }

  /// Create an expiry reminder 90 days before [expiryDate].
  ///
  /// Returns the reminder ID, or null if skipped (already exists or
  /// the lead-in window has already passed).
  Future<int?> createExpiryReminder(int documentId, DateTime expiryDate) {
    return AutoGenerateReminderUseCase(_database)(
      documentId: documentId,
      triggerTypeId: 'expiry_date',
      targetDate: expiryDate,
      leadInDays: 90,
      userNote:
          'Passport expires soon — allow time to renew before any trips.',
    );
  }
}
