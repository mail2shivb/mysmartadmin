import 'package:flutter/material.dart';
import '../../core/taxonomy/domain.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/typography.dart';
import '../../core/ui/theme_inherited_widget.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/insight_card.dart';

/// Categories screen
/// 
/// Displays the 8 hard-coded domains:
/// 1. Identity & Legal Documents (MVP priority)
/// 2. Vehicles & Transport
/// 3. Property & Home
/// 4. Insurance & Protection
/// 5. Banking & Credit
/// 6. Subscriptions & Memberships
/// 7. Employment & Income
/// 8. General Documents
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final domains = Domain.values.toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      enableScroll: true,
      padding: AppPadding.screen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by category',
            style: AppTypography.muted(context),
          ),
          const SizedBox(height: AppSpacing.md),
          ...domains.map((domain) => _DomainCard(domain: domain)),
        ],
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final Domain domain;

  const _DomainCard({required this.domain});

  Color _getIconBackground(BuildContext context) {
    final colors = AppThemeProvider.colorsOf(context);
    
    switch (domain) {
      case Domain.identityLegal:
        return colors.iconBackgroundBlue;
      case Domain.vehiclesTransport:
        return colors.iconBackgroundOrange;
      case Domain.propertyHome:
        return colors.iconBackgroundGreen;
      case Domain.insuranceProtection:
        return colors.iconBackgroundPurple;
      case Domain.bankingCredit:
        return colors.iconBackgroundBlue;
      case Domain.subscriptionsMemberships:
        return colors.iconBackgroundOrange;
      case Domain.employmentIncome:
        return colors.iconBackgroundGreen;
      case Domain.general:
        return colors.iconBackgroundGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeProvider.colorsOf(context);
    
    return InsightCard(
      leadingIcon: domain.icon,
      leadingIconBackground: _getIconBackground(context),
      leadingIconColor: Theme.of(context).colorScheme.primary,
      title: domain.displayName,
      subtitle: domain.priority == 1 ? 'Start here first' : null,
      badge: domain.priority == 1
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'MVP',
                style: AppTypography.labelSmall(context).copyWith(
                  color: colors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      trailingIcon: Icons.arrow_forward_ios,
      onTap: () {
        // TODO: Navigate to domain detail screen
      },
    );
  }
}
