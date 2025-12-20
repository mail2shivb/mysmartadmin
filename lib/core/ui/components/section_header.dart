import 'package:flutter/material.dart';
import '../tokens.dart';
import '../typography.dart';

/// Section header with title and optional trailing action
/// 
/// Used to separate logical sections within a screen.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium(context),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

