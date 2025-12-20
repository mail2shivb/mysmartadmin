import 'package:flutter/material.dart';

/// Consistent secondary button
/// 
/// Wraps OutlinedButton with consistent styling:
/// - Height: 48dp
/// - Padding: 24dp horizontal
/// - Border radius: 12dp
class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

