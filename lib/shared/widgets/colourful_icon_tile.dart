import 'package:flutter/material.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';

class ColourfulIconTile extends StatelessWidget {
  const ColourfulIconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.tint,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ProtoRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(ProtoSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(ProtoRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(ProtoRadius.md),
              ),
              child: Icon(icon, color: AppColors.deepPurple, size: 22),
            ),
            const SizedBox(height: ProtoSpacing.sm),
            Text(label,
                style: AppTextStyles.title.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
