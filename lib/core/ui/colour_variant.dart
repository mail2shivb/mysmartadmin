import 'package:flutter/material.dart';

/// Which colour palette the user has selected.
///
/// Independent of dark/light mode — the same variant can be used in
/// either brightness.
enum AppColourVariant {
  calmNeutral(
    displayName: 'Calm & Neutral',
    description: 'Classic blue-grey fintech palette',
    icon: Icons.water_drop_outlined,
    previewColour: Color(0xFF1E6FD9),
  ),
  lavender(
    displayName: 'Lavender',
    description: 'Soft violet palette from the new design',
    icon: Icons.auto_awesome_outlined,
    previewColour: Color(0xFF7C3AED),
  );

  final String displayName;
  final String description;
  final IconData icon;
  final Color previewColour;

  const AppColourVariant({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.previewColour,
  });
}
