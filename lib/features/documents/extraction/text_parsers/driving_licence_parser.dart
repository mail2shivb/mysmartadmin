import '../extraction_result.dart';
import 'date_token_parser.dart';

/// Parses OCR text from a UK DVLA photocard driving licence.
///
/// Extracts:
///   - Licence number  (DVLA format: LLLLLYYDDDDNNLL)
///   - Expiry date     (field 4b)
///   - Vehicle categories (field 9/10)
///   - Surname and given names (fields 1/2)
class DrivingLicenceParser {
  DrivingLicenceParser._();

  static final _licenceNumberRe = RegExp(
    r'\b([A-Z]{5}\d{6}[A-Z0-9]{2}[A-Z][\d]?[\d]?)\b',
  );

  static final _categoryRe = RegExp(
    r'\b(AM|A1|A2|A|B1|B|BE|C1|C1E|CE|C|D1|D1E|DE|D|F|G|H|K|L|P|Q|W)\b',
  );

  /// Attempt to parse [ocrText] into an [ExtractionResult].
  static ExtractionResult parse(String ocrText) {
    final upper = ocrText.toUpperCase();
    final lines = upper
        .split(RegExp(r'[\n\r]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String? licenceNumber;
    DateTime? expiryDate;
    String? categories;
    String? surname;
    String? givenNames;

    // ── Licence number ────────────────────────────────────────────────────────
    final lm = _licenceNumberRe.firstMatch(upper);
    if (lm != null) licenceNumber = lm.group(1);

    // ── Expiry date ───────────────────────────────────────────────────────────
    // Field 4b label appears as "4B" or "VALID TO" or "EXPIRY"
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('4B') ||
          lines[i].contains('VALID TO') ||
          lines[i].contains('EXPIRY') ||
          lines[i].contains('EXPIR')) {
        final searchText = lines.skip(i).take(3).join(' ');
        final found = DateTokenParser.parseAny(searchText);
        if (found != null) {
          expiryDate = found;
          break;
        }
      }
    }
    // Fallback: find any date in the full text
    expiryDate ??= DateTokenParser.parseAny(upper);

    // ── Vehicle categories ────────────────────────────────────────────────────
    final catMatches = _categoryRe.allMatches(upper).map((m) => m.group(1)!).toSet();
    if (catMatches.isNotEmpty) {
      // Sort for consistency: A, B, BE, C, D...
      final sorted = catMatches.toList()..sort();
      categories = sorted.join(', ');
    }

    // ── Name fields ───────────────────────────────────────────────────────────
    // Field 1 = surname, Field 2 = given names — often on first two content lines
    for (int i = 0; i < lines.length && i < 10; i++) {
      final l = lines[i];
      if (l.startsWith('1.') || l.startsWith('1 ')) {
        surname = l.replaceFirst(RegExp(r'^1[\.\s]+'), '').trim();
      } else if (l.startsWith('2.') || l.startsWith('2 ')) {
        givenNames = l.replaceFirst(RegExp(r'^2[\.\s]+'), '').trim();
      }
    }

    // Derive a title
    String? title;
    if (surname != null) {
      title = '${givenNames != null ? '$givenNames ' : ''}$surname Driving Licence';
    } else if (licenceNumber != null) {
      title = 'Driving Licence $licenceNumber';
    }

    return ExtractionResult(
      title: title,
      licenceNumber: licenceNumber,
      surname: surname,
      givenNames: givenNames,
      categories: categories,
      expiryDate: expiryDate,
    );
  }
}
