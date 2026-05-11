/// Shared date-token parser for extracting dates from OCR text.
///
/// Supports formats commonly found on UK identity documents:
///   - `YYMMDD`   (ICAO MRZ format)
///   - `DD MMM YYYY`  (e.g. "14 AUG 2026")
///   - `DD/MM/YYYY`
///   - `DD-MM-YYYY`
///   - `DD.MM.YYYY`
class DateTokenParser {
  DateTokenParser._();

  static const _months = {
    'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
    'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
  };

  /// Parses a 6-char ICAO MRZ date string `YYMMDD` to a [DateTime].
  ///
  /// Years 00–30 are interpreted as 2000–2030; 31–99 as 1931–1999.
  static DateTime? parseMrzDate(String mrzDate) {
    if (mrzDate.length != 6) return null;
    final yy = int.tryParse(mrzDate.substring(0, 2));
    final mm = int.tryParse(mrzDate.substring(2, 4));
    final dd = int.tryParse(mrzDate.substring(4, 6));
    if (yy == null || mm == null || dd == null) return null;
    final year = yy <= 30 ? 2000 + yy : 1900 + yy;
    return _tryDate(year, mm, dd);
  }

  /// Attempts to find any date in [text] using multiple formats.
  /// Returns the first successful parse.
  static DateTime? parseAny(String text) {
    final upper = text.toUpperCase();

    // dd MMM yyyy — e.g. "14 AUG 2026"
    final wordDate = RegExp(
        r'\b(\d{1,2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{4})\b');
    for (final m in wordDate.allMatches(upper)) {
      final d = int.tryParse(m.group(1)!);
      final mo = _months[m.group(2)];
      final y = int.tryParse(m.group(3)!);
      final result = _tryDate(y, mo, d);
      if (result != null) return result;
    }

    // dd/mm/yyyy, dd-mm-yyyy, dd.mm.yyyy
    final sepDate = RegExp(r'\b(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{4})\b');
    for (final m in sepDate.allMatches(text)) {
      final d = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final y = int.tryParse(m.group(3)!);
      final result = _tryDate(y, mo, d);
      if (result != null) return result;
    }

    return null;
  }

  static DateTime? _tryDate(int? y, int? m, int? d) {
    if (y == null || m == null || d == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }
}
