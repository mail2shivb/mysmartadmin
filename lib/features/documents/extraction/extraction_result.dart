/// Structured data extracted from a document file (image or PDF).
///
/// All fields are nullable — extraction may succeed partially.
/// Callers must treat every field as optional and display the form
/// for user review before saving.
class ExtractionResult {
  const ExtractionResult({
    this.title,
    this.passportNumber,
    this.surname,
    this.givenNames,
    this.nationality,
    this.licenceNumber,
    this.categories,
    this.issueDate,
    this.expiryDate,
    this.notice,
  });

  final String? title;
  final String? passportNumber;
  final String? surname;
  final String? givenNames;
  final String? nationality;
  final String? licenceNumber;
  final String? categories;
  final DateTime? issueDate;
  final DateTime? expiryDate;

  /// Optional human-readable notice to display above the form.
  ///
  /// Set by platform or format fallback implementations (e.g. desktop
  /// where OCR is unavailable, or when a PDF is uploaded).
  final String? notice;

  /// An empty result with no extracted fields.
  static const empty = ExtractionResult();
}
