import 'package:flutter/material.dart';
import '../tokens.dart';
import '../theme_inherited_widget.dart';

/// Domain icon with circular background
/// 
/// Used for displaying domain categories with subtle accent colors.
/// Adapts to current theme automatically.
class DomainIconBadge extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const DomainIconBadge({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  /// Small size variant (40dp)
  const DomainIconBadge.small({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  }) : size = AppSizes.avatarSmall;

  /// Medium size variant (48dp)
  const DomainIconBadge.medium({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  }) : size = AppSizes.avatarMedium;

  /// Large size variant (56dp)
  const DomainIconBadge.large({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  }) : size = AppSizes.avatarLarge;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeProvider.colorsOf(context);
    final badgeSize = size ?? AppSizes.avatarMedium;
    final iconSize = badgeSize * 0.5;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.iconBackground, // Use semantic icon background token
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? colors.primary,
      ),
    );
  }
}

