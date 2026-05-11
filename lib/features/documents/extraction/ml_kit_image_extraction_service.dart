import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../document_types.dart';
import 'document_extraction_service.dart';
import 'extraction_result.dart';
import 'text_parsers/driving_licence_parser.dart';
import 'text_parsers/passport_mrz_parser.dart';

/// On-device OCR using Google ML Kit Text Recognition.
///
/// Supported on Android and iOS only. The text recognizer runs entirely
/// on-device — no data is sent to any server.
///
/// The extracted text is passed to the appropriate document-type parser.
/// Results are partial; the user must always review and confirm before saving.
class MlKitImageExtractionService implements DocumentExtractionService {
  const MlKitImageExtractionService();

  @override
  Future<ExtractionResult> extract({
    required SupportedDocumentType type,
    required String filePath,
    required String mimeType,
  }) async {
    if (!_isImage(mimeType)) {
      return const ExtractionResult(
        notice:
            'PDF extraction is not available yet. '
            'You can still enter the details manually.',
      );
    }

    final inputImage = InputImage.fromFilePath(filePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(inputImage);
      final text = recognized.text;
      return switch (type) {
        SupportedDocumentType.passport => PassportMrzParser.parse(text),
        SupportedDocumentType.drivingLicence =>
          DrivingLicenceParser.parse(text),
      };
    } finally {
      recognizer.close();
    }
  }

  static bool _isImage(String mimeType) {
    return mimeType.startsWith('image/');
  }
}
