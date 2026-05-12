import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/proto_theme/app_colors.dart';
import '../services/attachment_service.dart';

class AttachmentField extends StatefulWidget {
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

  @override
  State<AttachmentField> createState() => _AttachmentFieldState();
}

class _AttachmentFieldState extends State<AttachmentField> {
  bool _picking = false;

  bool get _hasAnything => widget.picked != null || widget.existingPath != null;

  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final p = await AttachmentService.pick(context);
      if (p != null && mounted) widget.onPicked(p);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

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
          if (_picking)
            _loadingZone()
          else if (_hasAnything)
            _preview()
          else
            _empty(),
        ],
      ),
    );
  }

  Widget _loadingZone() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.softLavender,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.royalPurple,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading file…',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return GestureDetector(
      onTap: _pick,
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

  Widget _preview() {
    final isImage = _isImage(widget.picked?.mimeType ?? widget.existingMime);
    final fileName =
        widget.picked?.fileName ?? widget.existingPath?.split('/').last ?? '';
    final mime = widget.picked?.mimeType ?? widget.existingMime ?? 'file';
    final size = widget.picked?.sizeBytes ?? widget.existingSize;

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
              child: isImage && widget.picked != null
                  ? Image.file(File(widget.picked!.sourcePath),
                      fit: BoxFit.cover)
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
                  onTap: _pick,
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
            onPressed: widget.onClear,
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
