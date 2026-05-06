import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/database_provider.dart';
import '../../core/ui/components/primary_button.dart';
import '../../core/ui/tokens.dart';
import 'document_types.dart';
import 'driving_licence/driving_licence_view_model.dart';
import 'passport/passport_view_model.dart';
import 'widgets/driving_licence_form_fields.dart';
import 'widgets/passport_form_fields.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Unified document-creation screen.
///
/// Flow:
///   • If [initialType] is null  → Step 1: type selector → Step 2: form
///   • If [initialType] is given → Skip Step 1, show form immediately
///
/// Both steps live inside this single screen; no nested routes are involved.
/// The AppBar "back" in Step 2 returns to Step 1 when [initialType] is null,
/// or exits the screen when a type was pre-selected.
class AddDocumentScreen extends StatefulWidget {
  /// Pre-select a type and skip the type-selection step.
  final SupportedDocumentType? initialType;

  const AddDocumentScreen({super.key, this.initialType});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  SupportedDocumentType? _selectedType;
  bool _isSaving = false;

  // ── Shared controllers ────────────────────────────────────────────────────

  late final _titleController = TextEditingController(
    text: widget.initialType?.defaultTitle ?? '',
  );
  DateTime? _issueDate;
  DateTime? _expiryDate;

  // ── Passport-specific controllers ─────────────────────────────────────────

  final _passportNumberController = TextEditingController();
  final _surnameController = TextEditingController();
  final _givenNamesController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'British');

  // ── Driving licence-specific controllers ──────────────────────────────────

  final _licenceNumberController = TextEditingController();
  final _categoriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _passportNumberController.dispose();
    _surnameController.dispose();
    _givenNamesController.dispose();
    _nationalityController.dispose();
    _licenceNumberController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  // ── Type selection ────────────────────────────────────────────────────────

  void _selectType(SupportedDocumentType type) {
    _titleController.text = type.defaultTitle;
    // Reset dates so a previous session's dates don't bleed into the new type.
    _issueDate = null;
    _expiryDate = null;
    setState(() => _selectedType = type);
  }

  // ── Date picking ──────────────────────────────────────────────────────────

  Future<void> _pickDate({required bool isExpiry}) async {
    final today = DateTime.now();
    final initial = isExpiry
        ? (_expiryDate ?? today.add(const Duration(days: 3650)))
        : (_issueDate ?? today);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isExpiry ? 'Select expiry date' : 'Select issue date',
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) {
        _expiryDate = picked;
      } else {
        _issueDate = picked;
      }
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_issueDate == null) {
      _showError('Please select an issue date.');
      return;
    }
    if (_expiryDate == null) {
      _showError('Please select an expiry date.');
      return;
    }
    if (!_expiryDate!.isAfter(_issueDate!)) {
      _showError('Expiry date must be after issue date.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Delegate to the appropriate ViewModel; capture the reminder creator
      // as a function so the reminder dialog logic stays type-agnostic.
      final int documentId;
      final Future<int?> Function(int, DateTime) createReminder;

      switch (_selectedType!) {
        case SupportedDocumentType.passport:
          final vm = PassportViewModel(DatabaseProvider.instance);
          documentId = await vm.savePassport(
            title: _titleController.text,
            passportNumber: _passportNumberController.text,
            issueDate: _issueDate!,
            expiryDate: _expiryDate!,
            nationality: _nationalityController.text,
            surname: _surnameController.text,
            givenNames: _givenNamesController.text,
          );
          createReminder = vm.createExpiryReminder;

        case SupportedDocumentType.drivingLicence:
          final vm = DrivingLicenceViewModel(DatabaseProvider.instance);
          documentId = await vm.saveLicence(
            title: _titleController.text,
            licenceNumber: _licenceNumberController.text,
            issueDate: _issueDate!,
            expiryDate: _expiryDate!,
            categories: _categoriesController.text,
          );
          createReminder = vm.createExpiryReminder;
      }

      if (!mounted) return;

      final wantsReminder = await _showReminderDialog();
      if (wantsReminder == true) {
        await createReminder(documentId, _expiryDate!);
      }

      if (!mounted) return;
      context.pop();

      // ScaffoldMessenger is hosted above the route stack, so this is safe
      // to call immediately after pop.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedType!.displayName} saved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Could not save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Reminder dialog ───────────────────────────────────────────────────────

  Future<bool?> _showReminderDialog() => showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.notifications_outlined),
          title: Text(_selectedType!.reminderDialogTitle),
          content: Text(_selectedType!.reminderDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Set reminder'),
            ),
          ],
        ),
      );

  // ── Error helper ──────────────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // ── AppBar leading ────────────────────────────────────────────────────────

  /// When in form mode and no type was pre-selected, the back arrow returns
  /// to the type selector rather than exiting the screen.
  Widget? _buildLeading() {
    if (_selectedType != null && widget.initialType == null) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => setState(() => _selectedType = null),
        tooltip: 'Choose type',
      );
    }
    // null → GoRouter supplies the default back button (context.pop).
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appBarTitle = _selectedType == null
        ? 'Add Document'
        : 'Add ${_selectedType!.displayName}';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: _buildLeading(),
      ),
      body: SafeArea(
        child: _selectedType == null
            ? _buildTypeSelector(theme)
            : _buildForm(theme),
      ),
    );
  }

  // ── Step 1: type selector ─────────────────────────────────────────────────

  Widget _buildTypeSelector(ThemeData theme) {
    return ListView(
      padding: AppPadding.screen,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'What would you like to add?',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose a document type to continue.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...SupportedDocumentType.values.map(
          (type) => _TypeTile(
            icon: type.icon,
            title: type.displayName,
            subtitle: type.typeSubtitle,
            onTap: () => _selectType(type),
          ),
        ),
      ],
    );
  }

  // ── Step 2: form ──────────────────────────────────────────────────────────

  Widget _buildForm(ThemeData theme) {
    final type = _selectedType!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: AppPadding.screen,
        children: [
          // ── Document label ───────────────────────────────────────────────
          _SectionLabel('Document label'),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              helperText: 'A short name you will recognise in your document list',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title is required' : null,
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Type-specific fields (switch-based) ──────────────────────────
          _SectionLabel(type.detailsSectionLabel),
          const SizedBox(height: AppSpacing.xs),
          switch (type) {
            SupportedDocumentType.passport => PassportFormFields(
                passportNumberController: _passportNumberController,
                surnameController: _surnameController,
                givenNamesController: _givenNamesController,
                nationalityController: _nationalityController,
              ),
            SupportedDocumentType.drivingLicence => DrivingLicenceFormFields(
                licenceNumberController: _licenceNumberController,
                categoriesController: _categoriesController,
              ),
          },

          const SizedBox(height: AppSpacing.xl),

          // ── Dates ────────────────────────────────────────────────────────
          _SectionLabel('Dates'),
          const SizedBox(height: AppSpacing.xs),
          _DateTile(
            label: 'Issue date',
            date: _issueDate,
            onTap: () => _pickDate(isExpiry: false),
          ),
          const SizedBox(height: AppSpacing.md),
          _DateTile(
            label: type.expiryLabel,
            date: _expiryDate,
            onTap: () => _pickDate(isExpiry: true),
          ),

          const SizedBox(height: AppSpacing.xxl),

          PrimaryButton(
            label: type.saveLabel,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ── Private shared widgets ─────────────────────────────────────────────────────

/// Type-selection tile shown in Step 1.
class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: AppSizes.avatarSmall,
          height: AppSizes.avatarSmall,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconMedium,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Uppercase section label consistent with the rest of the form.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Tappable date field that wraps an [InputDecorator].
class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDate = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          hasDate ? _formatDate(date!) : 'Select date',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: hasDate ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day / $month / ${d.year}';
  }
}
