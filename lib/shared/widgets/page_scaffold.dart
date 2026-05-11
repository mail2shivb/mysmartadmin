import 'package:flutter/material.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';

/// Prototype Slack-style page scaffold:
/// purple header strip + rounded white content sheet.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerPurple,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ProtoSpacing.lg, ProtoSpacing.sm,
                ProtoSpacing.lg, ProtoSpacing.lg,
              ),
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTextStyles.headline
                                .copyWith(color: Colors.white)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!,
                              style: AppTextStyles.bodySecondary
                                  .copyWith(color: Colors.white70)),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft:  Radius.circular(ProtoRadius.xxl),
                    topRight: Radius.circular(ProtoRadius.xxl),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
