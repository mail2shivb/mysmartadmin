// F1 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// Empty state component for consistent placeholder UI
/// 
/// Features:
/// - Icon (contextual)
/// - Title (brief, friendly)
/// - Description (helpful, product-like)
/// - Optional primary action button
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Description text (optional)
  final String? description;

  /// Optional primary action button
  final VoidCallback? onActionPressed;

  /// Action button label
  final String? actionLabel;

  /// Custom icon size (defaults to 48)
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.onActionPressed,
    this.actionLabel,
    this.iconSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.outline,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

