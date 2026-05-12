import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/proto_theme/app_colors.dart';
import '../services/attachment_service.dart';

/// Section that lets the user attach a single photo/file to a record.
///
/// Shows an empty drop-zone when nothing is selected; once a file is picked
/// (or already saved), shows a preview tile with a remove button.
///
/// The widget is fully controlled — pass [picked] (a freshly-picked file
/// pending persistence) and/or [existingPath] (a relative path to a file
/// already saved in the app docs dir) and react to [onPicked] / [onClear].
class AttachmentField extends StatelessWidget {
  final PickedAttachment? picked;
  final String? existingPath;
  final String? existingMime;
  final int? existingSize;
  final ValueChanged<PickedAttachment> onPicked;
  final VoidCallback onClear;

  const AttachmentField({
    super.key,
    required this.picked,
    required this.onPicked,
    required this.onClear,
    this.existingPath,
    this.existingMime,
    this.existingSize,
  });

  bool get _hasAnything => picked != null || existingPath != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Text('Attachment',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          if (_hasAnything) _preview(context) else _empty(context),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final p = await AttachmentService.pick(context);
        if (p != null) onPicked(p);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.softLavender,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.border, style: BorderStyle.solid, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.paleLavender,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.attach_file_rounded,
                  color: AppColors.royalPurple, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Add photo or file',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text('Camera, gallery, or document picker',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
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

  Widget _preview(BuildContext context) {
    final isImage = _isImage(picked?.mimeType ?? existingMime);
    final fileName = picked?.fileName ?? existingPath?.split('/').last ?? '';
    final mime = picked?.mimeType ?? existingMime ?? 'file';
    final size = picked?.sizeBytes ?? existingSize;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.softLavender,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: isImage && picked != null
                  ? Image.file(File(picked!.sourcePath), fit: BoxFit.cover)
                  : Container(
                      color: AppColors.paleLavender,
                      alignment: Alignment.center,
                      child: Icon(_iconForMime(mime),
                          color: AppColors.royalPurple, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  _meta(mime, size),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () async {
                    final p = await AttachmentService.pick(context);
                    if (p != null) onPicked(p);
                  },
                  child: const Text('Replace',
                      style: TextStyle(
                          color: AppColors.royalPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textMuted),
            tooltip: 'Remove attachment',
          ),
        ],
      ),
    );
  }

  static String _meta(String mime, int? size) {
    final sizeStr = size == null ? '' : ' · ${_humanSize(size)}';
    return '$mime$sizeStr';
  }

  static String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool _isImage(String? mime) =>
      mime != null && mime.startsWith('image/');

  static IconData _iconForMime(String mime) {
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (mime.startsWith('text/')) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
