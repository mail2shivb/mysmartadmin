import '../document_types.dart';
import 'document_extraction_service.dart';
import 'extraction_result.dart';

/// Fallback extraction service for platforms where on-device OCR is not
/// available (macOS, Windows, Linux).
///
/// Returns an empty [ExtractionResult] with a [ExtractionResult.notice]
/// explaining the situation. The entry-method tiles (Take Photo / Choose File)
/// remain visible; tapping them triggers extraction which then shows this
/// notice above the blank form.
class UnsupportedPlatformExtractionService implements DocumentExtractionService {
  const UnsupportedPlatformExtractionService();

  static const _notice =
      'On-device OCR is not available on this platform yet — '
      'please enter the details manually.';

  @override
  Future<ExtractionResult> extract({
    required SupportedDocumentType type,
    required String filePath,
    required String mimeType,
  }) async {
    return const ExtractionResult(notice: _notice);
  }
}
