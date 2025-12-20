import 'package:flutter/material.dart';
import '../tokens.dart';

/// Consistent primary button
/// 
/// Wraps ElevatedButton with consistent styling:
/// - Height: 48dp
/// - Padding: 24dp horizontal
/// - Border radius: 12dp
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: AppSizes.iconSmall,
                height: AppSizes.iconSmall,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: AppSizes.iconMedium,
              height: AppSizes.iconMedium,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

