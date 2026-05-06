import 'package:flutter/material.dart';

/// Driving-licence-specific form fields for use inside [AddDocumentScreen].
///
/// Purely presentational: owns no state and performs no I/O.
/// Controllers are created and owned by the parent screen.
///
/// Fields rendered:
///   licence_number (required), categories (optional)
class DrivingLicenceFormFields extends StatelessWidget {
  final TextEditingController licenceNumberController;
  final TextEditingController categoriesController;

  const DrivingLicenceFormFields({
    super.key,
    required this.licenceNumberController,
    required this.categoriesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: licenceNumberController,
          decoration: const InputDecoration(
            labelText: 'Licence number',
            helperText: '16-character number from the front of your licence',
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Licence number is required'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: categoriesController,
          decoration: const InputDecoration(
            labelText: 'Licence categories (optional)',
            helperText:
                'Comma-separated codes from section 9, e.g. B, BE, AM',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }
}
