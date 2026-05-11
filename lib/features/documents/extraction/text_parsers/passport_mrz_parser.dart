import '../extraction_result.dart';
import 'date_token_parser.dart';

/// Parses OCR text from a machine-readable passport to extract structured
/// fields.
///
/// Understands ICAO Doc 9303 TD3 MRZ (two 44-char lines) as well as
/// partial matches for the visual inspection zone (VIZ).
class PassportMrzParser {
  PassportMrzParser._();

  /// Attempt to parse [ocrText] into an [ExtractionResult].
  ///
  /// Fields are populated only when the parser is confident; the rest
  /// remain null so the user reviews and fills them manually.
  static ExtractionResult parse(String ocrText) {
    final lines = ocrText
        .split(RegExp(r'[\n\r]+'))
        .map((l) => l.trim().toUpperCase())
        .where((l) => l.isNotEmpty)
        .toList();

    String? passportNumber;
    String? surname;
    String? givenNames;
    String? nationality;
    DateTime? expiryDate;

    // ── MRZ line 1: P<GBRSMITH<<JOHN<JAMES<<<<<<<<<<<<<<<<<< ─────────────────
    // Format: P<CCC + name field (39 chars, name separator <<, given name sep <)
    final mrzLine1Re = RegExp(r'^P[<A-Z][A-Z]{3}([A-Z<]{39})$');
    // ── MRZ line 2: passport number (9 chars) + check + nationality (3) + dob (6) + check + sex + expiry (6) + check ...
    final mrzLine2Re = RegExp(
        r'^([A-Z0-9<]{9})\d[A-Z]{3}(\d{6})\d[MFX<](\d{6})\d');

    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];

      // Match MRZ line 1
      final m1 = mrzLine1Re.firstMatch(l);
      if (m1 != null) {
        final namePart = m1.group(1)!;
        final sepIdx = namePart.indexOf('<<');
        if (sepIdx > 0) {
          surname = namePart.substring(0, sepIdx).replaceAll('<', ' ').trim();
          final given = namePart.substring(sepIdx + 2);
          givenNames = given.replaceAll('<', ' ').trim();
        }
        // Country code from positions 2–4 of full line
        if (l.length >= 5) nationality = _isoToReadable(l.substring(2, 5));
      }

      // Match MRZ line 2
      final m2 = mrzLine2Re.firstMatch(l);
      if (m2 != null) {
        passportNumber = m2.group(1)!.replaceAll('<', '');
        final expiryMrz = m2.group(3)!;
        expiryDate = DateTokenParser.parseMrzDate(expiryMrz);
      }
    }

    // ── Fallback: scan VIZ for dates if MRZ failed ────────────────────────────
    if (expiryDate == null) {
      // Look for lines near "EXPIRY" / "EXPIRATION" / "DATE OF EXPIRY"
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('EXPIR')) {
          final searchText = lines.skip(i).take(3).join(' ');
          expiryDate = DateTokenParser.parseAny(searchText);
          if (expiryDate != null) break;
        }
      }
    }

    // Derive a title from parsed name
    String? title;
    if (surname != null && givenNames != null) {
      title = '$givenNames $surname Passport';
    } else if (surname != null) {
      title = '$surname Passport';
    }

    return ExtractionResult(
      title: title,
      passportNumber: passportNumber,
      surname: surname,
      givenNames: givenNames,
      nationality: nationality,
      expiryDate: expiryDate,
    );
  }

  static String? _isoToReadable(String code) {
    const map = {
      'GBR': 'British',
      'USA': 'American',
      'IND': 'Indian',
      'CAN': 'Canadian',
      'AUS': 'Australian',
      'NZL': 'New Zealander',
      'IRL': 'Irish',
      'FRA': 'French',
      'DEU': 'German',
      'ESP': 'Spanish',
      'ITA': 'Italian',
      'NLD': 'Dutch',
      'POL': 'Polish',
      'PRT': 'Portuguese',
      'CHN': 'Chinese',
      'JPN': 'Japanese',
      'ZAF': 'South African',
      'PAK': 'Pakistani',
      'BGD': 'Bangladeshi',
      'NGA': 'Nigerian',
      'GHA': 'Ghanaian',
      'KEN': 'Kenyan',
    };
    return map[code.replaceAll('<', '')] ?? code.replaceAll('<', '');
  }
}
