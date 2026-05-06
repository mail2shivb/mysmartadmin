// B4.3 STATUS: IMPLEMENTED
// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/ui/tokens.dart';

/// Primary emphasis card component for KPIs and hero metrics
/// 
/// Features:
/// - Larger padding for visual emphasis
/// - Slightly more prominent depth
/// - Used ONCE per screen for the most important metric
class PrimaryCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Optional header widget (typically a title)
  final Widget? header;

  /// Custom padding (defaults to AppSpacing.xl for emphasis)
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
    final isDark = theme.brightness == Brightness.dark;
    
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl), // Larger padding
      child: header != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                header!,
                const SizedBox(height: AppSpacing.sm),
                child,
              ],
            )
          : child,
    );

    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16), // Slightly larger radius
        border: isDark 
          ? Border.all(
              color: theme.colorScheme.outline.withOpacity(0.15),
              width: 0.5,
            )
          : null,
        boxShadow: isDark
          ? [
              // Subtle top inner highlight for depth
              BoxShadow(
                color: Colors.white.withOpacity(0.04),
                blurRadius: 0,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ]
          : [
              // Primary shadow with subtle blue tint (more prominent)
              BoxShadow(
                color: const Color(0xFF1E40AF).withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              // Secondary shadow for depth
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      ),
    );
  }
}

