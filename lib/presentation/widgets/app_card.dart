// B4.3 STATUS: IMPLEMENTED
// F1 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/ui/tokens.dart';

/// Consistent card component used throughout the app
/// 
/// Features:
/// - Rounded corners
/// - Soft elevation
/// - Consistent padding
/// - Optional header slot
class AppCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Optional header widget (typically a title)
  final Widget? header;

  /// Custom padding (defaults to AppSpacing.md)
  final EdgeInsetsGeometry? padding;

  /// Custom margin (defaults to zero)
  final EdgeInsetsGeometry? margin;

  const AppCard({
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
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
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
        borderRadius: BorderRadius.circular(12),
        border: isDark 
          ? Border.all(
              color: theme.colorScheme.outline.withOpacity(0.12),
              width: 0.5,
            )
          : null,
        boxShadow: isDark
          ? [
              // Subtle top inner highlight for depth
              BoxShadow(
                color: Colors.white.withOpacity(0.03),
                blurRadius: 0,
                offset: const Offset(0, 0.5),
                spreadRadius: 0,
              ),
            ]
          : [
              // Primary shadow with subtle blue tint
              BoxShadow(
                color: const Color(0xFF1E40AF).withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              // Secondary shadow for depth
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      ),
    );
  }
}

