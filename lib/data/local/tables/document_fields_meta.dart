import 'package:drift/drift.dart';
import 'documents.dart';

/// DocumentFieldsMeta — per-field OCR vs user confirmation flags.
///
/// One row per document (1:1). Stores a JSON map tracking whether each
/// Zone A / Zone B field was filled by OCR or confirmed by the user.
///
/// Design rule (B6.4): OCR-filled values must never overwrite user-confirmed values.
/// This table provides the confirmation state the app checks before every OCR write.
///
/// Example [confirmationsJson] shape:
/// {
///   "expiry_date":      { "source": "ocr",    "confirmed": true  },
///   "reference_number": { "source": "ocr",    "confirmed": false },
///   "issuer":           { "source": "manual", "confirmed": true  }
/// }
@DataClassName('DocumentFieldsMetaEntity')
class DocumentFieldsMeta extends Table {
  // PK is the document ID — strictly 1:1, no separate autoincrement.
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();

  /// JSON map keyed by stable taxonomy field IDs.
  TextColumn get confirmationsJson =>
      text().withDefault(const Constant('{}'))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {documentId};
}
