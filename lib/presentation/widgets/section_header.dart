// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';

/// Section header component for consistent visual hierarchy
/// 
/// Features:
/// - Title with confident styling
/// - Optional trailing action (e.g., "See all")
/// - Strong top margin for clear section separation
class SectionHeader extends StatelessWidget {
  /// Section title
  final String title;

  /// Optional trailing widget (e.g., TextButton)
  final Widget? trailing;

  /// Custom title style
  final TextStyle? titleStyle;

  /// Add top margin (default: true) - ignored in F1.6, spacing managed by screens
  final bool addTopMargin;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.titleStyle,
    this.addTopMargin = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = titleStyle ?? theme.textTheme.titleLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: effectiveStyle,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

