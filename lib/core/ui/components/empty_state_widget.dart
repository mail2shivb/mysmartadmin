import 'package:flutter/material.dart';
import '../tokens.dart';
import '../typography.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Premium empty state widget with reassuring copy
/// 
/// Features:
/// - Large icon (subtle color)
/// - Title and description
/// - Primary CTA button
/// - Optional secondary button
/// - Privacy-first, reassuring microcopy
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.primaryButtonLabel,
    this.onPrimaryButtonPressed,
    this.secondaryButtonLabel,
    this.onSecondaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon,
              size: AppSizes.iconXLarge,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              description,
              style: AppTypography.muted(context),
              textAlign: TextAlign.center,
            ),

            // Buttons
            if (primaryButtonLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                onPressed: onPrimaryButtonPressed,
                label: primaryButtonLabel!,
              ),
            ],

            if (secondaryButtonLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                onPressed: onSecondaryButtonPressed,
                label: secondaryButtonLabel!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

