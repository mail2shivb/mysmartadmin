// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/empty_state_widget.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/policies_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';

/// Policies screen
///
/// Displays policy information using PoliciesViewModel.
/// Pure presentation logic - no business rules, no calculations.
/// Uses visual hierarchy: PrimaryCard for total coverage (hero KPI).
class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repository = ReportsRepository(db);
    final viewModel = PoliciesViewModel(repository);
    final theme = Theme.of(context);

    return AppScaffold(
      useSafeArea: true,
      enableScroll: true,
      body: Padding(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Coverage (PRIMARY KPI)
            FutureBuilder(
              future: viewModel.loadTotalCoverageAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const PrimaryCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return PrimaryCard(
                    child: EmptyStateWidget(
                      icon: Icons.security_outlined,
                      title: 'Your coverage summary is not available yet',
                      description:
                          'This screen is designed to keep insurance cover easy to review, so important protection details stay clear and accessible.',
                    ),
                  );
                }
                final totalCoverage = snapshot.data!;
                if (totalCoverage == 0) {
                  return PrimaryCard(
                    child: EmptyStateWidget(
                      icon: Icons.policy_outlined,
                      title: 'No insurance records are being tracked yet',
                      description:
                          'When policies are added, you will be able to review cover, renewal timing, and costs in one place.',
                    ),
                  );
                }
                return PrimaryCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          size: 44,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '£${(totalCoverage / 100).toStringAsFixed(2)}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'total cover recorded',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // SECTION: Active Cover
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Active Cover'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.countActivePolicies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.shield_outlined,
                      title: 'Your policy overview is not available yet',
                      description:
                          'This section helps you see how many active policies you are currently tracking on this device.',
                    ),
                  );
                }
                final count = snapshot.data!;
                if (count == 0) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.policy_outlined,
                      title: 'No active policies are being tracked yet',
                      description:
                          'Once you record a policy, this section will help you keep cover details and renewals visible.',
                    ),
                  );
                }
                return AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active policies',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '$count',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // SECTION: Premium Summary
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Premium Summary'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadPoliciesMonthlyTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.payments_outlined,
                      title: 'Your premium summary is not available yet',
                      description:
                          'This section is intended to show the regular cost of your policies, so you can understand what protection costs over time.',
                    ),
                  );
                }
                final total = snapshot.data!;
                return AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments,
                        size: 32,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tracked monthly premium',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '£${(total / 100).toStringAsFixed(2)}',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md), // Bottom padding
          ],
        ),
      ),
    );
  }
}
