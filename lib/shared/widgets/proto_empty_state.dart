import 'package:flutter/material.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';

class ProtoEmptyState extends StatelessWidget {
  const ProtoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });
  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ProtoSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primaryPurple),
            const SizedBox(height: ProtoSpacing.md),
            Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: ProtoSpacing.sm),
              Text(message!, style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
