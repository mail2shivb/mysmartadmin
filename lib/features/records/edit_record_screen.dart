import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/l_widgets.dart';
import 'services/attachment_service.dart';
import 'widgets/attachment_field.dart';

/// Edit Record — loads an existing [DocumentEntity] by id, lets the user
/// update its fields and attachment, and writes the changes back.
class EditRecordScreen extends StatefulWidget {
  final int? recordId;
  const EditRecordScreen({super.key, this.recordId});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _titleCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DocumentEntity? _doc;
  DateTime? _expiryDate;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  // Attachment state.
  PickedAttachment? _newAttachment; // freshly picked, not yet persisted
  String? _existingPath;
  String? _existingMime;
  int? _existingSize;
  bool _attachmentCleared = false; // user removed the existing attachment

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _providerCtrl.dispose();
    _referenceCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.recordId;
    if (id == null) {
      setState(() {
        _loading = false;
        _loadError = 'No record id supplied.';
      });
      return;
    }
    try {
      final doc = await DatabaseProvider.instance.documentsDao
          .getDocumentById(id);
      if (!mounted) return;
      if (doc == null) {
        setState(() {
          _loading = false;
          _loadError = 'Record #$id not found.';
        });
        return;
      }
      _doc = doc;
      _titleCtrl.text = doc.title;
      _providerCtrl.text = doc.issuer ?? '';
      _referenceCtrl.text = doc.referenceNumber ?? '';
      _amountCtrl.text = doc.amountCents != null
          ? (doc.amountCents! / 100).toStringAsFixed(2)
          : '';
      _expiryDate = doc.expiryDate;

      final extras = _decodeExtras(doc.extraFieldsJson);
      _notesCtrl.text = extras['notes']?.toString() ?? '';

      _existingPath = doc.filePath;
      _existingMime = doc.fileMime;
      _existingSize = doc.fileSizeBytes;

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load record: $e';
      });
    }
  }

  int? _parseAmountToCents(String text) {
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!);
    if (v == null) return null;
    return (v * 100).round();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: AppColors.royalPurple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _save() async {
    final id = _doc?.id;
    if (id == null) return;
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Title cannot be empty')));
      return;
    }

    setState(() => _saving = true);
    try {
      final amountText = _amountCtrl.text.trim();
      final amountCents =
          amountText.isEmpty ? null : _parseAmountToCents(amountText);

      // Merge notes back into extraFieldsJson, preserving any unknown keys.
      final extras = _decodeExtras(_doc?.extraFieldsJson);
      final notes = _notesCtrl.text.trim();
      if (notes.isEmpty) {
        extras.remove('notes');
      } else {
        extras['notes'] = notes;
      }
      if (amountText.isNotEmpty && amountCents == null) {
        extras['amount_raw'] = amountText;
      } else {
        extras.remove('amount_raw');
      }

      // Resolve attachment changes.
      String? newPath = _existingPath;
      String? newMime = _existingMime;
      int? newSize = _existingSize;
      String? oldPathToDelete;

      if (_newAttachment != null) {
        final stored = await AttachmentService.persist(_newAttachment!,
            recordId: id);
        if (_existingPath != null && _existingPath != stored.relativePath) {
          oldPathToDelete = _existingPath;
        }
        newPath = stored.relativePath;
        newMime = stored.mimeType;
        newSize = stored.sizeBytes;
      } else if (_attachmentCleared && _existingPath != null) {
        oldPathToDelete = _existingPath;
        newPath = null;
        newMime = null;
        newSize = null;
      }

      await DatabaseProvider.instance.documentsDao.updateDocumentFields(
        id,
        DocumentsCompanion(
          title: Value(_titleCtrl.text.trim()),
          issuer: Value(_providerCtrl.text.trim().isEmpty
              ? null
              : _providerCtrl.text.trim()),
          referenceNumber: Value(_referenceCtrl.text.trim().isEmpty
              ? null
              : _referenceCtrl.text.trim()),
          amountCents: Value(amountCents),
          expiryDate: Value(_expiryDate),
          extraFieldsJson:
              Value(extras.isEmpty ? null : jsonEncode(extras)),
          filePath: Value(newPath),
          fileMime: Value(newMime),
          fileSizeBytes: Value(newSize),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (oldPathToDelete != null) {
        await AttachmentService.deleteRelative(oldPathToDelete);
      }

      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Record updated'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Edit record',
      onBack: () => Navigator.of(context).maybePop(),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
              color: AppColors.primaryPurple, strokeWidth: 2),
        ),
      );
    }
    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: LEmptyState(
          icon: Icons.error_outline,
          title: 'Cannot edit record',
          message: _loadError!,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LCard(
            child: Column(
              children: [
                LField(label: 'Title', controller: _titleCtrl),
                LField(
                    label: 'Provider / Issuer', controller: _providerCtrl),
                LField(
                    label: 'Reference / Policy number',
                    controller: _referenceCtrl),
                LField(label: 'Amount', controller: _amountCtrl),
                _DateRow(
                  label: 'Renewal / Expiry date',
                  date: _expiryDate,
                  onPick: _pickDate,
                  onClear: () => setState(() => _expiryDate = null),
                ),
                LField(label: 'Notes', controller: _notesCtrl),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: AttachmentField(
              picked: _newAttachment,
              existingPath: _attachmentCleared ? null : _existingPath,
              existingMime: _attachmentCleared ? null : _existingMime,
              existingSize: _attachmentCleared ? null : _existingSize,
              onPicked: (p) => setState(() {
                _newAttachment = p;
                _attachmentCleared = false;
              }),
              onClear: () => setState(() {
                _newAttachment = null;
                _attachmentCleared = true;
              }),
            ),
          ),
          const SizedBox(height: 16),
          LPrimaryButton(
            label: _saving ? 'Saving…' : 'Save changes',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _decodeExtras(String? json) {
  if (json == null || json.isEmpty) return <String, dynamic>{};
  try {
    final v = jsonDecode(json);
    return v is Map<String, dynamic>
        ? Map<String, dynamic>.of(v)
        : <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DateRow({
    required this.label,
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final display = date != null
        ? '${date!.day.toString().padLeft(2, '0')} / '
            '${date!.month.toString().padLeft(2, '0')} / '
            '${date!.year}'
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          GestureDetector(
            onTap: onPick,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.softLavender,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16,
                      color: display != null
                          ? AppColors.royalPurple
                          : AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      display ?? 'DD / MM / YYYY',
                      style: TextStyle(
                        color: display != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (display != null)
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
