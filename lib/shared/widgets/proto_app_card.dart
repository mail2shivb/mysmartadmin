import 'package:flutter/material.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_shadows.dart';
import '../../core/proto_theme/app_spacing.dart';

/// Prototype-style white card with subtle lavender shadow and divider border.
class ProtoAppCard extends StatelessWidget {
  const ProtoAppCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(ProtoSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(ProtoRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
