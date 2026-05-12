import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/l_widgets.dart';
import 'services/attachment_service.dart';
import 'widgets/attachment_field.dart';

class AddRecordScreen extends StatefulWidget {
  final String mode;
  const AddRecordScreen({super.key, this.mode = 'manual'});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  static const _categories = [
    'Identity & Legal',
    'Insurance & Protection',
    'Bills, Utilities & Subscriptions',
    'Home & Property',
    'Vehicles & Transport',
    'Banking, Credit & Borrowing',
    'Work, Income & Tax',
    'Person & Family Profile',
  ];

  static const _recordTypes = [
    'Passport',
    'Driving Licence',
    'Home Insurance Policy',
    'Car Insurance Policy',
    'Electricity Bill',
    'Mortgage Statement',
    'Payslip',
    'Employment Contract',
    'Proof of Address',
    'Bank Statement',
    'Credit Card Statement',
  ];

  String? _category;
  String? _recordType;
  DateTime? _expiryDate;
  PickedAttachment? _attachment;

  final _titleCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _providerCtrl.dispose();
    _referenceCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Labels that adapt to the selected record type ────────────────────────

  String get _modeSubtitle => switch (widget.mode) {
        'scan' => 'Scan mode',
        'camera' => 'Camera mode',
        'library' => 'From library',
        'import' => 'Import from files',
        _ => 'Manual entry',
      };

  String get _modeLabel => switch (widget.mode) {
        'scan' => 'Scan',
        'camera' => 'Camera',
        'library' => 'Library',
        'import' => 'Import',
        _ => 'Manual',
      };

  String get _providerLabel => switch (_recordType) {
        'Passport' || 'Driving Licence' => 'Issuing Authority',
        'Payslip' || 'Employment Contract' => 'Employer',
        'Bank Statement' || 'Credit Card Statement' || 'Mortgage Statement' => 'Bank / Lender',
        _ => 'Provider / Issuer',
      };

  String get _referenceLabel => switch (_recordType) {
        'Passport' => 'Passport Number',
        'Driving Licence' => 'Licence Number',
        'Bank Statement' || 'Credit Card Statement' => 'Account Number',
        'Payslip' => 'Payroll / Employee ID',
        'Mortgage Statement' => 'Mortgage Reference',
        _ => 'Reference / Policy Number',
      };

  String get _expiryLabel => switch (_recordType) {
        'Passport' || 'Driving Licence' => 'Expiry Date',
        'Employment Contract' => 'Contract End Date',
        'Payslip' => 'Pay Period End Date',
        'Electricity Bill' || 'Mortgage Statement' => 'Statement / Due Date',
        _ => 'Renewal / Expiry Date',
      };

  bool get _showAmount => switch (_recordType) {
        'Passport' || 'Driving Licence' || 'Proof of Address' => false,
        _ => true,
      };

  String get _amountLabel => switch (_recordType) {
        'Payslip' => 'Net Pay',
        'Mortgage Statement' => 'Monthly Payment',
        'Electricity Bill' => 'Amount Due',
        'Bank Statement' || 'Credit Card Statement' => 'Balance',
        _ => 'Amount / Premium',
      };

  // ── Validation & save ────────────────────────────────────────────────────

  /// Map UI category label → (domainId, default categoryId) used by the vault
  /// taxonomy. Keys must match the strings shown in the picker exactly.
  static const _categoryToTaxonomy = <String, ({String domain, String category})>{
    'Identity & Legal':
        (domain: 'identity_legal', category: 'personal_identity'),
    'Insurance & Protection':
        (domain: 'insurance_protection', category: 'general_insurance'),
    'Bills, Utilities & Subscriptions':
        (domain: 'bills_utilities_subscriptions', category: 'utilities'),
    'Home & Property': (domain: 'home_property', category: 'home'),
    'Vehicles & Transport':
        (domain: 'vehicles_transport', category: 'vehicle'),
    'Banking, Credit & Borrowing':
        (domain: 'banking_credit_borrowing', category: 'banking'),
    'Work, Income & Tax': (domain: 'work_income_tax', category: 'employment'),
    'Person & Family Profile':
        (domain: 'person_family', category: 'people'),
  };

  /// Map UI record-type label → canonical documentTypeId.
  static const _recordTypeIds = <String, String>{
    'Passport': 'passport',
    'Driving Licence': 'driving_licence',
    'Home Insurance Policy': 'home_insurance',
    'Car Insurance Policy': 'car_insurance',
    'Electricity Bill': 'electricity_bill',
    'Mortgage Statement': 'mortgage_statement',
    'Payslip': 'payslip',
    'Employment Contract': 'employment_contract',
    'Proof of Address': 'proof_of_address',
    'Bank Statement': 'bank_statement',
    'Credit Card Statement': 'credit_card_statement',
  };

  /// Pull the first numeric value out of free-form text (e.g. "£12.99 / month")
  /// and convert it to pence. Returns null when no number is present.
  int? _parseAmountToCents(String text) {
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!);
    if (v == null) return null;
    return (v * 100).round();
  }

  Future<void> _save() async {
    final newErrors = <String, String>{};
    if (_titleCtrl.text.trim().isEmpty) {
      newErrors['title'] = 'Please enter a title';
    }
    if (_category == null) newErrors['category'] = 'Please choose a category';
    if (_recordType == null) {
      newErrors['recordType'] = 'Please choose a record type';
    }
    setState(() => _errors
      ..clear()
      ..addAll(newErrors));
    if (newErrors.isNotEmpty) return;

    final tax = _categoryToTaxonomy[_category!] ??
        (domain: 'identity_legal', category: 'general');
    final docTypeId = _recordTypeIds[_recordType!] ??
        _recordType!.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

    final amountText = _amountCtrl.text.trim();
    final amountCents =
        amountText.isEmpty ? null : _parseAmountToCents(amountText);

    // Zone B: free-form fields the schema does not normalise.
    final extra = <String, dynamic>{
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (amountText.isNotEmpty && amountCents == null)
        'amount_raw': amountText,
      if (widget.mode != 'manual') 'entry_mode': widget.mode,
    };

    try {
      final db = DatabaseProvider.instance;
      final newId = await db.transaction<int>(() async {
        final id = await db.documentsDao.insertDocument(
          DocumentsCompanion.insert(
            title: _titleCtrl.text.trim(),
            issuer: Value(_providerCtrl.text.trim().isEmpty
                ? null
                : _providerCtrl.text.trim()),
            referenceNumber: Value(_referenceCtrl.text.trim().isEmpty
                ? null
                : _referenceCtrl.text.trim()),
            amountCents: Value(amountCents),
            expiryDate: Value(_expiryDate),
            extraFieldsJson:
                Value(extra.isEmpty ? null : jsonEncode(extra)),
            source: const Value('manual'),
          ),
        );
        await db.documentsDao.classify(
          id: id,
          documentTypeId: docTypeId,
          categoryId: tax.category,
          domainId: tax.domain,
          taxonomyVersion: 1,
        );
        return id;
      });

      // Persist the attachment after insert so we can scope it under
      // /records/<id>/. We update the row with the resulting metadata.
      if (_attachment != null) {
        final stored =
            await AttachmentService.persist(_attachment!, recordId: newId);
        await db.documentsDao.updateDocumentFields(
          newId,
          DocumentsCompanion(
            filePath: Value(stored.relativePath),
            fileMime: Value(stored.mimeType),
            fileSizeBytes: Value(stored.sizeBytes),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 17),
          SizedBox(width: 8),
          Text('Record saved securely'),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.go(AppRouter.vault);
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Draft saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRouter.vault);
    }
  }

  // ── Date picker ──────────────────────────────────────────────────────────

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

  // ── Picker bottom sheet ──────────────────────────────────────────────────

  void _showPicker(String title, List<String> options, ValueChanged<String> onPick) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(options[i],
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.textMuted),
                  onTap: () {
                    onPick(options[i]);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Reusable field builders ──────────────────────────────────────────────

  Widget _selectField({
    required String label,
    required String? value,
    required String placeholder,
    required String? errorText,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.softLavender,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: errorText != null ? AppColors.error : AppColors.border),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        color: value != null
                            ? AppColors.royalPurple
                            : AppColors.textMuted,
                        size: 16),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      value ?? placeholder,
                      style: TextStyle(
                        color: value != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted, size: 18),
                ],
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 2),
              child: Text(errorText,
                  style: const TextStyle(color: AppColors.error, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? errorText,
    IconData? icon,
    bool multiline = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: multiline ? 4 : 1,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            onChanged: errorText != null
                ? (_) => setState(() => _errors.remove('title'))
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: icon != null
                  ? Icon(icon, size: 16, color: AppColors.textMuted)
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              filled: true,
              fillColor: AppColors.softLavender,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: multiline ? 12 : 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: errorText != null ? AppColors.error : AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: errorText != null ? AppColors.error : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryPurple, width: 1.5),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 2),
              child: Text(errorText,
                  style: const TextStyle(color: AppColors.error, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _dateField() {
    final display = _expiryDate != null
        ? '${_expiryDate!.day.toString().padLeft(2, '0')} / '
            '${_expiryDate!.month.toString().padLeft(2, '0')} / '
            '${_expiryDate!.year}'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(_expiryLabel,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                      onTap: () => setState(() => _expiryDate = null),
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

  Widget _sectionLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add Record',
      subtitle: _modeSubtitle,
      onBack: _cancel,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Entry method chip
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paleLavender,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.input_outlined,
                        size: 12, color: AppColors.royalPurple),
                    const SizedBox(width: 4),
                    Text(
                      'Entry method: $_modeLabel',
                      style: const TextStyle(
                        color: AppColors.deepPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Classification
            _sectionLabel('Classification', Icons.label_outline),
            LCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Column(
                children: [
                  _selectField(
                    label: 'Category',
                    value: _category,
                    placeholder: 'Choose category',
                    errorText: _errors['category'],
                    icon: Icons.folder_outlined,
                    onTap: () => _showPicker('Category', _categories, (v) {
                      setState(() {
                        _category = v;
                        _errors.remove('category');
                      });
                    }),
                  ),
                  _selectField(
                    label: 'Record Type',
                    value: _recordType,
                    placeholder: 'Choose record type',
                    errorText: _errors['recordType'],
                    icon: Icons.description_outlined,
                    onTap: () => _showPicker('Record Type', _recordTypes, (v) {
                      setState(() {
                        _recordType = v;
                        _errors.remove('recordType');
                      });
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details
            _sectionLabel('Details', Icons.edit_outlined),
            LCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Column(
                children: [
                  _textField(
                    label: 'Title *',
                    hint: 'e.g. AXA Home Insurance',
                    controller: _titleCtrl,
                    errorText: _errors['title'],
                    icon: Icons.title_outlined,
                    onTap: () => setState(() => _errors.remove('title')),
                  ),
                  _textField(
                    label: _providerLabel,
                    hint: _providerLabel,
                    controller: _providerCtrl,
                    icon: Icons.business_outlined,
                  ),
                  _textField(
                    label: _referenceLabel,
                    hint: _referenceLabel,
                    controller: _referenceCtrl,
                    icon: Icons.numbers_outlined,
                  ),
                  _dateField(),
                  if (_showAmount)
                    _textField(
                      label: '$_amountLabel (optional)',
                      hint: 'e.g. £12.99 / month',
                      controller: _amountCtrl,
                      icon: Icons.currency_pound_outlined,
                    ),
                  _textField(
                    label: 'Notes',
                    hint: 'Additional notes…',
                    controller: _notesCtrl,
                    icon: Icons.notes_outlined,
                    multiline: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Attachment
            _sectionLabel('Attachment', Icons.attach_file_rounded),
            LCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: AttachmentField(
                picked: _attachment,
                onPicked: (p) => setState(() => _attachment = p),
                onClear: () => setState(() => _attachment = null),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy
            Row(
              children: const [
                Icon(Icons.lock_outline, size: 13, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Saved locally in your private vault.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Buttons
            LPrimaryButton(label: 'Save Record', onPressed: _save),
            const SizedBox(height: 10),
            LGhostButton(label: 'Save Draft', onPressed: _saveDraft),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _cancel,
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
