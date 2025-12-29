// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// Primary emphasis card component for KPIs and hero metrics
/// 
/// Features:
/// - Larger padding for visual emphasis
/// - Subtle shadow for depth
/// - Used ONCE per screen for the most important metric
/// - Same white surface as StandardCard
class PrimaryCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Optional header widget (typically a title)
  final Widget? header;

  /// Custom padding (defaults to Spacing.xl for emphasis)
  final EdgeInsetsGeometry? padding;

  /// Custom margin (defaults to zero)
  final EdgeInsetsGeometry? margin;

  const PrimaryCard({
    super.key,
    required this.child,
    this.header,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(Spacing.xl), // Larger padding
      child: header != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                header!,
                const SizedBox(height: Spacing.sm),
                child,
              ],
            )
          : child,
    );

    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest, // White
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08), // Subtle shadow
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: cardContent,
    );
  }
}

