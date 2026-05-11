import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

import '../document_types.dart';
import 'extraction_result.dart';
import 'ml_kit_image_extraction_service.dart';
import 'unsupported_platform_extraction_service.dart';

/// Contract for extracting structured fields from a document file.
///
/// Use [DocumentExtractionService.instance] to get the platform-appropriate
/// implementation:
///   - Android / iOS  → [MlKitImageExtractionService] (on-device, private)
///   - macOS / Windows / Linux → [UnsupportedPlatformExtractionService]
///     (shows an honest "enter manually" notice; UI buttons remain visible)
abstract class DocumentExtractionService {
  Future<ExtractionResult> extract({
    required SupportedDocumentType type,
    required String filePath,
    required String mimeType,
  });

  /// Returns the platform-appropriate service implementation.
  static DocumentExtractionService get instance {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return const MlKitImageExtractionService();
      default:
        return const UnsupportedPlatformExtractionService();
    }
  }
}

/// Stub service used only in tests and UI previews.
///
/// Never registered via [DocumentExtractionService.instance] in production.
class StubExtractionService implements DocumentExtractionService {
  const StubExtractionService();

  @override
  Future<ExtractionResult> extract({
    required SupportedDocumentType type,
    required String filePath,
    required String mimeType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ExtractionResult.empty;
  }
}
