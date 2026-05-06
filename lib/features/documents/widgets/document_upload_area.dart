import 'package:flutter/material.dart';

import '../../../core/ui/tokens.dart';

/// The three rendering states of [DocumentUploadArea].
enum UploadAreaState {
  /// No file has been picked yet. Not shown externally — method tiles handle
  /// the selection step.
  idle,

  /// A file has been picked and field extraction is in progress.
  extracting,

  /// Extraction completed. Fields have been pre-populated for review.
  done,
}

/// Purely presentational widget that renders extraction progress and result.
///
/// State is owned by the parent screen. This widget is only shown when
/// [state] is [UploadAreaState.extracting] or [UploadAreaState.done].
class DocumentUploadArea extends StatelessWidget {
  const DocumentUploadArea({
    super.key,
    required this.state,
    this.fileName,
    required this.onTap,
  });

  final UploadAreaState state;

  /// Name of the file being processed, shown as a subtitle.
  final String? fileName;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      UploadAreaState.idle => const SizedBox.shrink(),
      UploadAreaState.extracting => _ExtractingView(fileName: fileName),
      UploadAreaState.done => _DoneView(fileName: fileName),
    };
  }
}

// ── Extracting ─────────────────────────────────────────────────────────────────

class _ExtractingView extends StatelessWidget {
  const _ExtractingView({this.fileName});
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading document…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (fileName != null)
                  Text(
                    fileName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Done ───────────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  const _DoneView({this.fileName});
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fields filled in. Review before saving.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (fileName != null)
                  Text(
                    fileName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
