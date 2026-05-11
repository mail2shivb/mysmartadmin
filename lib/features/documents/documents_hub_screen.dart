import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';

/// Documents hub — exact layout from the prototype screenshot:
///  • Identity & Travel section (Passports + Driving licence)
///  • Coming soon section (Property docs + Insurance policies)
///  • Privacy footer
class DocumentsHubScreen extends StatelessWidget {
  const DocumentsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Documents',
      subtitle: 'Passports, licences, contracts and more',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          tooltip: 'Add document',
          onPressed: () => context.go(AppRouter.addDocument),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(ProtoSpacing.lg),
        children: [
          // ── Identity & Travel ──────────────────────────────────────────
          Text('Identity & Travel', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),

          _DocumentTypeTile(
            icon: Icons.book_rounded,
            title: 'Passports',
            subtitle: 'Track expiry dates and get renewal reminders',
            onTap: () => context.go(AppRouter.passportList),
          ),
          const SizedBox(height: ProtoSpacing.sm),
          _DocumentTypeTile(
            icon: Icons.directions_car_rounded,
            title: 'Driving licence',
            subtitle: 'Photocard expiry and licence category records',
            onTap: () => context.go(AppRouter.drivingLicenceList),
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Coming soon ────────────────────────────────────────────────
          Text('Coming soon', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),

          _DocumentTypeTile(
            icon: Icons.home_rounded,
            title: 'Property documents',
            subtitle: 'Deeds, mortgages, and tenancy agreements',
            comingSoon: true,
          ),
          const SizedBox(height: ProtoSpacing.sm),
          _DocumentTypeTile(
            icon: Icons.shield_rounded,
            title: 'Insurance policies',
            subtitle: 'Home, vehicle, and life insurance',
            comingSoon: true,
          ),

          const SizedBox(height: ProtoSpacing.xl),

          // ── Privacy footer ─────────────────────────────────────────────
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ProtoSpacing.lg),
              child: Text(
                'Your device is the system of record. Nothing leaves this app without your permission.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
            ),
          ),
          const SizedBox(height: ProtoSpacing.xxxl),
        ],
      ),
    );
  }
}

class _DocumentTypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  const _DocumentTypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProtoAppCard(
      padding: const EdgeInsets.all(ProtoSpacing.lg),
      child: InkWell(
        onTap: comingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(ProtoRadius.lg),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: comingSoon
                    ? AppColors.softLavender
                    : AppColors.paleLavender,
                borderRadius: BorderRadius.circular(ProtoRadius.md),
              ),
              child: Icon(
                icon,
                color: comingSoon
                    ? AppColors.textMuted
                    : AppColors.deepPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: ProtoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 15,
                      color: comingSoon
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            if (comingSoon)
              const Text('Soon',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ))
            else
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
