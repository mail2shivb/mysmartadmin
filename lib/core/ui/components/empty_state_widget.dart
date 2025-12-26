import 'package:flutter/material.dart';
import '../tokens.dart';
import '../typography.dart';
import '../theme_inherited_widget.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Premium empty state widget with reassuring copy
/// 
/// Features:
/// - Large icon with subtle background circle
/// - Title and description with proper hierarchy
/// - Primary CTA button
/// - Optional secondary button
/// - Privacy-first, reassuring microcopy
/// - Adapts to current theme automatically
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
    final colors = AppThemeProvider.colorsOf(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with subtle background circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.iconBackground, // Use semantic icon background token
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48, // Larger icon
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              description,
              style: AppTypography.bodyLarge(context).copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Buttons
            if (primaryButtonLabel != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                onPressed: onPrimaryButtonPressed,
                label: primaryButtonLabel!,
              ),
            ],

            if (secondaryButtonLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
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

