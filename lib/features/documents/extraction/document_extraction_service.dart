import '../document_types.dart';
import 'extraction_result.dart';

/// Contract for extracting structured fields from a document file.
///
/// Concrete implementations call an OCR / ML pipeline.
/// Use [DocumentExtractionService.instance] to get the active implementation;
/// swap [StubExtractionService] for a real class when OCR is ready without
/// touching any calling code.
abstract class DocumentExtractionService {
  Future<ExtractionResult> extract({
    required SupportedDocumentType type,
    required String filePath,
    required String mimeType,
  });

  /// Returns the active service implementation.
  static DocumentExtractionService get instance => const StubExtractionService();
}

/// Mock service that returns realistic test data after a simulated delay.
///
/// [ExtractionResult.isStub] is set to `true` so the UI can surface a
/// "demo data" notice. Replace this class with a real OCR implementation
/// when the pipeline is ready.
class StubExtractionService implements DocumentExtractionService {
  const StubExtractionService();

  @override
  Future<ExtractionResult> extract({
    required SupportedDocumentType type,
    required String filePath,
    required String mimeType,
  }) async {
    // Simulate OCR processing latency.
    await Future.delayed(const Duration(milliseconds: 1500));

    return switch (type) {
      SupportedDocumentType.passport => ExtractionResult(
          title: 'My Passport',
          passportNumber: '123456789',
          surname: 'SMITH',
          givenNames: 'JOHN JAMES',
          nationality: 'British',
          issueDate: DateTime(2020, 1, 15),
          expiryDate: DateTime(2030, 1, 14),
          isStub: true,
        ),
      SupportedDocumentType.drivingLicence => ExtractionResult(
          title: 'My Driving Licence',
          licenceNumber: 'SMITH901015JJ9AB',
          categories: 'B, BE',
          issueDate: DateTime(2018, 5, 20),
          expiryDate: DateTime(2033, 5, 19),
          isStub: true,
        ),
    };
  }
}
