// F1 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../theme/spacing.dart';

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

  /// Custom padding (defaults to Spacing.md)
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
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(Spacing.md),
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

    return Card(
      margin: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }
}

