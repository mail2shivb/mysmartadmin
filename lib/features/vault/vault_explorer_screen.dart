// REBUILT: prototype-faithful VaultExplorerScreen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../shared/widgets/colourful_icon_tile.dart';
import '../../shared/widgets/page_scaffold.dart';

/// Vault Explorer — prototype-faithful category grid with search bar.
class VaultExplorerScreen extends StatelessWidget {
  const VaultExplorerScreen({super.key});

  static const _categories = [
    (Icons.badge_rounded,          'Identity & Legal',     AppColors.paleLavender),
    (Icons.home_rounded,           'Home & Property',      AppColors.tileBlue),
    (Icons.directions_car_rounded, 'Vehicles',             AppColors.tileGreen),
    (Icons.account_balance_rounded,'Banking & Credit',     AppColors.tileSlate),
    (Icons.shield_rounded,         'Insurance',            AppColors.tileCoral),
    (Icons.receipt_long_rounded,   'Bills & Utilities',    AppColors.tileAmber),
    (Icons.work_rounded,           'Work & Income',        AppColors.tileIndigo),
    (Icons.people_rounded,         'People & Family',      AppColors.tileBrown),
  ];

  static const _categoryIds = [
    'identity_legal',
    'home_property',
    'vehicles_transport',
    'banking_credit',
    'insurance',
    'bills_utilities',
    'work_income_tax',
    'person_family',
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Vault',
      subtitle: 'Your secure records, on this device',
      child: ListView(
        padding: const EdgeInsets.all(ProtoSpacing.lg),
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRouter.search),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ProtoSpacing.md, vertical: ProtoSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.softLavender,
                borderRadius: BorderRadius.circular(ProtoRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textMuted),
                  SizedBox(width: ProtoSpacing.sm),
                  Text('Search records, people, bills…',
                      style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Category grid ──────────────────────────────────────────────
          Text('Categories', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: ProtoSpacing.sm,
            crossAxisSpacing: ProtoSpacing.sm,
            childAspectRatio: 1.5,
            children: List.generate(_categories.length, (i) {
              final (icon, label, tint) = _categories[i];
              final categoryId = _categoryIds[i];
              return ColourfulIconTile(
                icon: icon,
                label: label,
                tint: tint,
                onTap: () => context.go(
                  '/vault/category/$categoryId',
                ),
              );
            }),
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Review queue ───────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.paleLavender,
                borderRadius: BorderRadius.circular(ProtoRadius.md),
              ),
              child: const Icon(Icons.fact_check_rounded,
                  color: AppColors.deepPurple),
            ),
            title: const Text('Review queue',
                style: AppTextStyles.title),
            subtitle: const Text('Items waiting for your review',
                style: AppTextStyles.bodySecondary),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textMuted),
            onTap: () => context.go(AppRouter.documents),
          ),

          const SizedBox(height: ProtoSpacing.xxxl),
        ],
      ),
    );
  }
}
