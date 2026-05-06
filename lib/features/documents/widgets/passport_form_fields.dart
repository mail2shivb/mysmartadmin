import 'package:flutter/material.dart';

/// Passport-specific form fields for use inside [AddDocumentScreen].
///
/// Purely presentational: owns no state and performs no I/O.
/// Controllers are created and owned by the parent screen.
///
/// Fields rendered:
///   passport_number (required), surname, given_names, nationality (all optional)
class PassportFormFields extends StatelessWidget {
  final TextEditingController passportNumberController;
  final TextEditingController surnameController;
  final TextEditingController givenNamesController;
  final TextEditingController nationalityController;

  const PassportFormFields({
    super.key,
    required this.passportNumberController,
    required this.surnameController,
    required this.givenNamesController,
    required this.nationalityController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: passportNumberController,
          decoration: const InputDecoration(
            labelText: 'Passport number',
            helperText: '9-character code printed at the top of the data page',
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Passport number is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: surnameController,
          decoration: const InputDecoration(
            labelText: 'Surname (optional)',
            helperText: 'As printed in the passport',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: givenNamesController,
          decoration: const InputDecoration(
            labelText: 'Given names (optional)',
            helperText: 'As printed in the passport',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nationalityController,
          decoration: const InputDecoration(
            labelText: 'Nationality (optional)',
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
