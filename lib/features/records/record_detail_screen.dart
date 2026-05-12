import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/l_widgets.dart';
import 'services/attachment_service.dart';

/// Record Detail — loads a [DocumentEntity] by id and renders its fields.
/// Returns content only — ShellScaffold provides gradient header + back button.
class RecordDetailScreen extends StatefulWidget {
  final int? recordId;
  const RecordDetailScreen({super.key, this.recordId});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late Future<DocumentEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<DocumentEntity?> _fetch() async {
    final id = widget.recordId;
    if (id == null) return null;
    return DatabaseProvider.instance.documentsDao.getDocumentById(id);
  }

  void _refresh() => setState(() => _future = _fetch());

  Future<void> _confirmAndDelete(DocumentEntity doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this record?'),
        content: Text(
            '“${doc.title}” will be moved to the recycle bin. Any linked file '
            'will also be removed from the device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await DatabaseProvider.instance.documentsDao.softDeleteDocument(doc.id);
      if (doc.filePath != null) {
        await AttachmentService.deleteRelative(doc.filePath!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
      return;
    }

    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Record deleted'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recordId == null) {
      return const _NotFound(message: 'No record id supplied.');
    }
    return FutureBuilder<DocumentEntity?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                  color: AppColors.primaryPurple, strokeWidth: 2),
            ),
          );
        }
        final doc = snap.data;
        if (doc == null) {
          return _NotFound(message: 'Record #${widget.recordId} not found.');
        }
        return _RecordBody(
          doc: doc,
          onEdit: () async {
            await context.push(AppRouter.editRecordPath(doc.id));
            if (!mounted) return;
            _refresh();
          },
          onDelete: () => _confirmAndDelete(doc),
        );
      },
    );
  }
}

class _RecordBody extends StatelessWidget {
  final DocumentEntity doc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RecordBody({
    required this.doc,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final extras = _decodeExtras(doc.extraFieldsJson);
    final notes = extras['notes']?.toString();
    final amount = doc.amountCents != null
        ? '£${(doc.amountCents! / 100).toStringAsFixed(2)}'
        : (extras['amount_raw']?.toString());

    final kvs = <(String, String)>[
      if (doc.documentTypeId != null)
        ('Type', _humanise(doc.documentTypeId!)),
      if (doc.domainId != null)
        ('Category', _humanise(doc.domainId!)),
      if (doc.issuer != null && doc.issuer!.isNotEmpty)
        ('Provider / Issuer', doc.issuer!),
      if (doc.referenceNumber != null && doc.referenceNumber!.isNotEmpty)
        ('Reference', doc.referenceNumber!),
      if (doc.expiryDate != null)
        ('Renewal / Expiry', _formatDate(doc.expiryDate!)),
      if (doc.issueDate != null) ('Issued', _formatDate(doc.issueDate!)),
      if (amount != null) ('Amount', amount),
      ('Saved', _formatDate(doc.createdAt)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // ── Status badges ────────────────────────────────────────────────
        Row(
          children: [
            if (doc.expiryDate != null)
              StatusBadge(
                kind: _badgeKind(doc.expiryDate!),
                label: _statusLabel(doc.expiryDate!),
              ),
            if (doc.expiryDate != null) const SizedBox(width: 8),
            if (doc.documentTypeId != null)
              StatusBadge(
                kind: BadgeKind.info,
                label: _humanise(doc.documentTypeId!),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Title card ───────────────────────────────────────────────────
        LCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              if (doc.description != null && doc.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(doc.description!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Field list ───────────────────────────────────────────────────
        const SectionTitle('Details'),
        LCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final kv in kvs) _KV(kv.$1, kv.$2),
            ],
          ),
        ),

        // ── Notes ────────────────────────────────────────────────────────
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 14),
          const SectionTitle('Notes'),
          LCard(
            child: Text(notes,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
          ),
        ],

        // ── Attachments (linked file, if any) ───────────────────────────
        if (doc.filePath != null) ...[
          const SizedBox(height: 14),
          const SectionTitle('Attachments'),
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: ListRow(
              icon: Icons.description_outlined,
              title: doc.filePath!.split('/').last,
              subtitle: doc.fileMime,
            ),
          ),
        ],

        const SizedBox(height: 18),

        // ── Actions ──────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: LPrimaryButton(label: 'Edit', onPressed: onEdit),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LGhostButton(
                label: 'Replace',
                onPressed: () => context.push(AppRouter.replaceRecord),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LGhostButton(
          label: 'Version history',
          onPressed: () => context.push(AppRouter.versionHistory),
        ),
        const SizedBox(height: 16),
        // Destructive action kept visually separated at the bottom, matching
        // iOS/Material conventions for irreversible operations.
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Delete record'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  final String message;
  const _NotFound({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
      children: [
        LEmptyState(
          icon: Icons.error_outline,
          title: 'Record unavailable',
          message: message,
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Map<String, dynamic> _decodeExtras(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    final v = jsonDecode(json);
    return v is Map<String, dynamic> ? v : const {};
  } catch (_) {
    return const {};
  }
}

String _humanise(String id) => id
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

BadgeKind _badgeKind(DateTime expiry) {
  final days = expiry.difference(DateTime.now()).inDays;
  if (days < 0) return BadgeKind.urgent;
  if (days <= 30) return BadgeKind.expiring;
  return BadgeKind.success;
}

String _statusLabel(DateTime expiry) {
  final days = expiry.difference(DateTime.now()).inDays;
  if (days < 0) return 'Expired';
  if (days <= 30) return 'Expiring ${_formatDate(expiry)}';
  return 'Active until ${_formatDate(expiry)}';
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(k,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
          ],
        ),
      );
}
