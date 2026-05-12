import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/proto_theme/app_colors.dart';

/// Lightweight description of a file the user has just picked.
///
/// The path may point at a temp/cache location returned by `image_picker` or
/// `file_picker` — call [AttachmentService.persist] before storing it in the
/// database so the file lives in a stable, app-owned directory.
class PickedAttachment {
  final String sourcePath;
  final String fileName;
  final String? mimeType;
  final int? sizeBytes;

  const PickedAttachment({
    required this.sourcePath,
    required this.fileName,
    this.mimeType,
    this.sizeBytes,
  });
}

/// Final on-disk attachment metadata to persist on the documents row.
class StoredAttachment {
  /// Path relative to the application documents directory.
  /// Stored verbatim in `documents.file_path`.
  final String relativePath;
  final String? mimeType;
  final int sizeBytes;

  const StoredAttachment({
    required this.relativePath,
    required this.mimeType,
    required this.sizeBytes,
  });
}

enum _PickSource { camera, gallery, file }

class AttachmentService {
  AttachmentService._();

  /// Show the standard "Attach" bottom sheet (Take Photo / Choose from Library
  /// / Choose File) and return the user's choice, or null if they cancelled.
  ///
  /// The sheet closes BEFORE the OS picker opens, so the app never appears
  /// frozen during image compression or iCloud downloads.
  static Future<PickedAttachment?> pick(BuildContext context) async {
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Attach a photo or file',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _SheetTile(
              icon: Icons.camera_alt_outlined,
              title: 'Take photo',
              subtitle: 'Use the camera to photograph a document',
              onTap: () => Navigator.of(sheetCtx).pop(_PickSource.camera),
            ),
            _SheetTile(
              icon: Icons.image_outlined,
              title: 'Choose from library',
              subtitle: 'Pick an image from your photos',
              onTap: () => Navigator.of(sheetCtx).pop(_PickSource.gallery),
            ),
            _SheetTile(
              icon: Icons.upload_file_outlined,
              title: 'Choose file',
              subtitle: 'PDF, image, or any saved document',
              onTap: () => Navigator.of(sheetCtx).pop(_PickSource.file),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return null;

    // Sheet is fully dismissed before OS picker opens — no visible freeze.
    return switch (source) {
      _PickSource.camera => _pickFromCamera(),
      _PickSource.gallery => _pickFromGallery(),
      _PickSource.file => _pickFile(),
    };
  }

  static Future<PickedAttachment?> _pickFromCamera() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera);
    if (x == null) return null;
    final size = await File(x.path).length();
    return PickedAttachment(
      sourcePath: x.path,
      fileName: x.name,
      mimeType: 'image/jpeg',
      sizeBytes: size,
    );
  }

  static Future<PickedAttachment?> _pickFromGallery() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return null;
    final size = await File(x.path).length();
    return PickedAttachment(
      sourcePath: x.path,
      fileName: x.name,
      mimeType: x.mimeType ?? 'image/jpeg',
      sizeBytes: size,
    );
  }

  static Future<PickedAttachment?> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp', 'doc', 'docx', 'txt',
      ],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.first;
    final path = f.path;
    if (path == null) return null;
    return PickedAttachment(
      sourcePath: path,
      fileName: f.name,
      mimeType: _mimeFromExtension(f.extension),
      sizeBytes: f.size,
    );
  }

  /// Copy [picked] into the app documents directory under
  /// `records/<recordId>/<filename>` so the file survives temp-cache eviction.
  /// Returns metadata to store on the row.
  static Future<StoredAttachment> persist(
    PickedAttachment picked, {
    required int recordId,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final targetDir =
        Directory(p.join(docsDir.path, 'records', recordId.toString()));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final safeName = _sanitiseFileName(picked.fileName);
    final target = File(p.join(targetDir.path, safeName));
    await File(picked.sourcePath).copy(target.path);

    final size = await target.length();
    final relative = p.relative(target.path, from: docsDir.path);

    return StoredAttachment(
      relativePath: relative,
      mimeType: picked.mimeType,
      sizeBytes: size,
    );
  }

  /// Delete a previously-persisted attachment file. Best-effort; missing
  /// files are silently ignored.
  static Future<void> deleteRelative(String relativePath) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final f = File(p.join(docsDir.path, relativePath));
      if (await f.exists()) await f.delete();
    } catch (_) {/* swallow */}
  }

  static String _sanitiseFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'attachment' : cleaned;
  }

  static String? _mimeFromExtension(String? ext) {
    if (ext == null) return null;
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return null;
    }
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.paleLavender,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.royalPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
