// B4.3 STATUS: IMPLEMENTED

import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/primary_button.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/tokens.dart';
import 'document_types.dart';
import 'driving_licence/driving_licence_view_model.dart';
import 'extraction/document_extraction_service.dart';
import 'extraction/extraction_result.dart';
import 'passport/passport_view_model.dart';
import 'widgets/document_upload_area.dart';
import 'widgets/driving_licence_form_fields.dart';
import 'widgets/passport_form_fields.dart';

/// How the user wants to create the document record.
enum EntryMethod {
  /// User fills every field by hand — form opens immediately.
  manual,

  /// User captures a photo with the device camera.
  takePhoto,

  /// User picks an image or PDF from the device file system.
  chooseFile,
}

/// Documents hub with an inline "add document" panel.
///
/// Tapping + in the AppBar toggles add mode. In add mode:
///   1. User selects a document type.
///   2. User selects an entry method (manual / camera / file).
///   3a. Manual     → empty form shown immediately.
///   3b. takePhoto  → camera opens; extraction runs; form pre-populated.
///   3c. chooseFile → file picker opens; extraction runs; form pre-populated.
///   4. User reviews / edits and saves.
///
/// No navigation is involved — the entire flow lives in this screen.
class DocumentsFunctionalScreen extends StatefulWidget {
  const DocumentsFunctionalScreen({super.key});

  @override
  State<DocumentsFunctionalScreen> createState() =>
      _DocumentsFunctionalScreenState();
}

class _DocumentsFunctionalScreenState
    extends State<DocumentsFunctionalScreen> {
  // ── Scroll ─────────────────────────────────────────────────────────────────

  final _scrollController = ScrollController();

  // ── Add-mode toggle ────────────────────────────────────────────────────────

  bool _addMode = false;

  // ── Form state ─────────────────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  SupportedDocumentType? _selectedType;
  EntryMethod? _entryMethod;
  bool _isSaving = false;

  // Shared
  final _titleController = TextEditingController();
  DateTime? _issueDate;
  DateTime? _expiryDate;

  // Passport-specific
  final _passportNumberController = TextEditingController();
  final _surnameController = TextEditingController();
  final _givenNamesController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'British');

  // Driving licence-specific
  final _licenceNumberController = TextEditingController();
  final _categoriesController = TextEditingController();

  // ── Upload / extraction state ───────────────────────────────────────────────

  UploadAreaState _uploadState = UploadAreaState.idle;
  String? _pickedFileName;
  String? _extractionNotice;

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _passportNumberController.dispose();
    _surnameController.dispose();
    _givenNamesController.dispose();
    _nationalityController.dispose();
    _licenceNumberController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  // ── State helpers ──────────────────────────────────────────────────────────

  void _toggleAddMode() {
    final opening = !_addMode;
    setState(() {
      _addMode = opening;
      if (!opening) _clearFormData();
    });
    if (opening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: AppDurations.medium,
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _clearFormData() {
    _selectedType = null;
    _entryMethod = null;
    _titleController.clear();
    _passportNumberController.clear();
    _surnameController.clear();
    _givenNamesController.clear();
    _nationalityController.text = 'British';
    _licenceNumberController.clear();
    _categoriesController.clear();
    _issueDate = null;
    _expiryDate = null;
    _uploadState = UploadAreaState.idle;
    _pickedFileName = null;
    _formKey.currentState?.reset();
  }

  void _onTypeSelected(SupportedDocumentType? type) {
    if (type == null) return;
    setState(() {
      _selectedType = type;
      _titleController.text = type.defaultTitle;
      _entryMethod = null;
      _issueDate = null;
      _expiryDate = null;
      _uploadState = UploadAreaState.idle;
      _pickedFileName = null;
    });
  }

  // ── Platform capability ────────────────────────────────────────────────────

  /// True on iOS and Android where a hardware camera is available.
  bool get _hasCameraSupport =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  // ── Entry method selection & dispatch ─────────────────────────────────────

  Future<void> _onEntryMethodTapped(EntryMethod method) async {
    // Reset upload state whenever the user changes method so a fresh
    // extraction cycle starts.
    setState(() {
      _entryMethod = method;
      _uploadState = UploadAreaState.idle;
      _pickedFileName = null;
    });

    switch (method) {
      case EntryMethod.manual:
        // Form is shown immediately — no async action needed.
        break;
      case EntryMethod.takePhoto:
        await _takePhoto();
      case EntryMethod.chooseFile:
        await _chooseFile();
    }
  }

  // ── Camera ─────────────────────────────────────────────────────────────────

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (!mounted) return;
    if (photo == null) {
      // User cancelled — reset method selection so they can choose again.
      setState(() => _entryMethod = null);
      return;
    }

    setState(() {
      _pickedFileName = photo.name;
      _uploadState = UploadAreaState.extracting;
    });

    await _runExtraction(filePath: photo.path, mimeType: 'image/jpeg');
  }

  // ── File picker ────────────────────────────────────────────────────────────

  Future<void> _chooseFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'],
      allowMultiple: false,
      withData: false,
    );

    if (!mounted) return;
    if (result == null || result.files.isEmpty) {
      setState(() => _entryMethod = null);
      return;
    }

    final file = result.files.first;
    final filePath = file.path;
    if (filePath == null) {
      setState(() => _entryMethod = null);
      return;
    }

    setState(() {
      _pickedFileName = file.name;
      _uploadState = UploadAreaState.extracting;
    });

    final mime = _mimeFromExtension(file.extension ?? '');
    await _runExtraction(filePath: filePath, mimeType: mime);
  }

  // ── Shared extraction runner ───────────────────────────────────────────────

  Future<void> _runExtraction({
    required String filePath,
    required String mimeType,
  }) async {
    try {
      final extracted = await DocumentExtractionService.instance.extract(
        type: _selectedType!,
        filePath: filePath,
        mimeType: mimeType,
      );

      if (!mounted) return;
      setState(() {
        _uploadState = UploadAreaState.done;
        _extractionNotice = extracted.notice;
        _populateFromResult(extracted);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadState = UploadAreaState.idle;
        _pickedFileName = null;
      });
      _showError('Could not extract fields: $e');
    }
  }

  // ── Field population ───────────────────────────────────────────────────────

  void _populateFromResult(ExtractionResult result) {
    if (result.title != null) _titleController.text = result.title!;
    if (result.passportNumber != null) {
      _passportNumberController.text = result.passportNumber!;
    }
    if (result.surname != null) _surnameController.text = result.surname!;
    if (result.givenNames != null) _givenNamesController.text = result.givenNames!;
    if (result.nationality != null) {
      _nationalityController.text = result.nationality!;
    }
    if (result.licenceNumber != null) {
      _licenceNumberController.text = result.licenceNumber!;
    }
    if (result.categories != null) _categoriesController.text = result.categories!;
    if (result.issueDate != null) _issueDate = result.issueDate;
    if (result.expiryDate != null) _expiryDate = result.expiryDate;
  }

  // ── Date picking ───────────────────────────────────────────────────────────

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

  // ── Save ───────────────────────────────────────────────────────────────────

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
      final savedName = _selectedType!.displayName;
      setState(() {
        _addMode = false;
        _clearFormData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$savedName saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Could not save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Reminder dialog ────────────────────────────────────────────────────────

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

  // ── Mime helper ────────────────────────────────────────────────────────────

  static String _mimeFromExtension(String ext) => switch (ext.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'heic' => 'image/heic',
        'webp' => 'image/webp',
        'pdf' => 'application/pdf',
        _ => 'application/octet-stream',
      };

  // ── Error helper ───────────────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: AppDurations.short,
              child: _addMode
                  ? const Icon(Icons.close, key: ValueKey('close'))
                  : const Icon(Icons.add, key: ValueKey('add')),
            ),
            tooltip: _addMode ? 'Cancel' : 'Add document',
            onPressed: _toggleAddMode,
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: AppPadding.screen,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          // ── Inline add panel ─────────────────────────────────────────────
          AnimatedSize(
            duration: AppDurations.medium,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _addMode
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _buildAddPanel(theme),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Category tiles ───────────────────────────────────────────────
          const SectionHeader(title: 'Identity & Travel'),
          const SizedBox(height: AppSpacing.xs),
          _CategoryTile(
            icon: Icons.book_outlined,
            title: 'Passports',
            subtitle: 'Track expiry dates and get renewal reminders',
            onTap: () => context.go(AppRouter.passportList),
          ),
          _CategoryTile(
            icon: Icons.directions_car_outlined,
            title: 'Driving licence',
            subtitle: 'Photocard expiry and licence category records',
            onTap: () => context.go(AppRouter.drivingLicenceList),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Coming soon'),
          const SizedBox(height: AppSpacing.xs),
          _CategoryTile(
            icon: Icons.home_outlined,
            title: 'Property documents',
            subtitle: 'Deeds, mortgages, and tenancy agreements',
            enabled: false,
          ),
          _CategoryTile(
            icon: Icons.receipt_long_outlined,
            title: 'Insurance policies',
            subtitle: 'Home, vehicle, and life insurance',
            enabled: false,
          ),

          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'Your device is the system of record. '
              'Nothing leaves this app without your permission.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ── Add panel ──────────────────────────────────────────────────────────────

  Widget _buildAddPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppPadding.card,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step 1: document type ────────────────────────────────────
              DropdownButtonFormField<SupportedDocumentType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Document type',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                hint: const Text('Choose a type to continue'),
                items: SupportedDocumentType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon,
                                size: 18,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(type.displayName),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _onTypeSelected,
              ),

              // ── Steps 2 + 3: entry method and dynamic content ────────────
              AnimatedSize(
                duration: AppDurations.medium,
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _selectedType == null
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: AppSpacing.md),

                          // ── Step 2: entry method tiles ───────────────────
                          _FormSectionLabel('How would you like to add this?'),
                          const SizedBox(height: AppSpacing.sm),
                          _EntryMethodTile(
                            icon: Icons.edit_outlined,
                            title: 'Enter details manually',
                            selected: _entryMethod == EntryMethod.manual,
                            onTap: () =>
                                _onEntryMethodTapped(EntryMethod.manual),
                          ),
                          if (_hasCameraSupport)
                            _EntryMethodTile(
                              icon: Icons.camera_alt_outlined,
                              title: 'Take a photo',
                              subtitle: 'Capture the document with your camera',
                              selected: _entryMethod == EntryMethod.takePhoto,
                              onTap: () =>
                                  _onEntryMethodTapped(EntryMethod.takePhoto),
                            ),
                          _EntryMethodTile(
                            icon: Icons.attach_file_outlined,
                            title: 'Choose a file',
                            subtitle: 'Select an image or PDF from your device',
                            selected: _entryMethod == EntryMethod.chooseFile,
                            onTap: () =>
                                _onEntryMethodTapped(EntryMethod.chooseFile),
                          ),

                          // ── Step 3: extraction progress / result ─────────
                          if (_entryMethod != null &&
                              _entryMethod != EntryMethod.manual &&
                              _uploadState != UploadAreaState.idle) ...[
                            const SizedBox(height: AppSpacing.md),
                            DocumentUploadArea(
                              state: _uploadState,
                              fileName: _pickedFileName,
                              onTap: null,
                            ),
                          ],

                          // ── Step 4: editable form ────────────────────────
                          if (_entryMethod == EntryMethod.manual ||
                              _uploadState == UploadAreaState.done)
                            _buildFormFields(theme),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form fields ────────────────────────────────────────────────────────────

  Widget _buildFormFields(ThemeData theme) {
    final type = _selectedType!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.lg),

        if (_extractionNotice != null) ..._buildNoticeBanner(_extractionNotice!, theme),

        _FormSectionLabel('Document label'),
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

        const SizedBox(height: AppSpacing.lg),

        _FormSectionLabel(type.detailsSectionLabel),
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

        const SizedBox(height: AppSpacing.lg),

        _FormSectionLabel('Dates'),
        const SizedBox(height: AppSpacing.xs),
        _DateInputTile(
          label: 'Issue date',
          date: _issueDate,
          onTap: () => _pickDate(isExpiry: false),
        ),
        const SizedBox(height: AppSpacing.md),
        _DateInputTile(
          label: type.expiryLabel,
          date: _expiryDate,
          onTap: () => _pickDate(isExpiry: true),
        ),

        const SizedBox(height: AppSpacing.xl),

        PrimaryButton(
          label: type.saveLabel,
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  // ── Extraction notice banner ────────────────────────────────────────────────

  List<Widget> _buildNoticeBanner(String message, ThemeData theme) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
    ];
  }
}

// ── Entry method tile ──────────────────────────────────────────────────────────

/// Tappable option card for selecting how to add a document.
class _EntryMethodTile extends StatelessWidget {
  const _EntryMethodTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: selected
              ? color.withValues(alpha: 0.35)
              : theme.colorScheme.outline.withValues(alpha: 0.15),
          width: selected ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconMedium,
                color: selected
                    ? color
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected ? color : theme.colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private shared widgets ─────────────────────────────────────────────────────

class _FormSectionLabel extends StatelessWidget {
  final String text;
  const _FormSectionLabel(this.text);

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

class _DateInputTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateInputTile({
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

// ── Category tile ──────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
          width: 0.5,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: AppSizes.avatarSmall,
          height: AppSizes.avatarSmall,
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconMedium,
            color: enabled
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(color: effectiveColor),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant
                .withValues(alpha: enabled ? 1.0 : 0.5),
          ),
        ),
        trailing: enabled
            ? Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : Text(
                'Soon',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}
