import 'package:flutter/material.dart';
import '../tokens.dart';
import '../typography.dart';
import '../theme_inherited_widget.dart';

/// Premium card for displaying information
/// 
/// Features:
/// - Optional leading icon with colored background
/// - Title and subtitle text
/// - Optional badge
/// - Optional trailing icon
/// - Consistent styling
/// - Adapts to current theme automatically
class InsightCard extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Color? leadingIconBackground;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const InsightCard({
    super.key,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingIconBackground,
    required this.title,
    this.subtitle,
    this.badge,
    this.trailingIcon,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeProvider.colorsOf(context);
    
    final card = Card(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: AppPadding.card,
          child: Row(
            children: [
              // Leading icon
              if (leadingIcon != null) ...[
                Container(
                  width: AppSizes.avatarSmall,
                  height: AppSizes.avatarSmall,
                  decoration: BoxDecoration(
                    color: leadingIconBackground ?? colors.iconBackground, // Use semantic token
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: AppSizes.iconMedium,
                    color: leadingIconColor ?? colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],

              // Title, subtitle, badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.titleMedium(context),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          badge!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTypography.muted(context),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing icon
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  trailingIcon,
                  size: AppSizes.iconSmall,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return card;
  }
}

