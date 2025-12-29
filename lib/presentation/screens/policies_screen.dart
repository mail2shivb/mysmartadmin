// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/policies_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';
import '../theme/spacing.dart';

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
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
                        padding: EdgeInsets.all(Spacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return PrimaryCard(
                    child: EmptyState(
                      icon: Icons.security_outlined,
                      title: 'Coverage data loading',
                    ),
                  );
                }
                final totalCoverage = snapshot.data!;
                if (totalCoverage == 0) {
                  return PrimaryCard(
                    child: EmptyState(
                      icon: Icons.policy_outlined,
                      title: 'No policies recorded yet',
                      description: 'Add your first policy to see coverage',
                    ),
                  );
                }
                return PrimaryCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          '£${(totalCoverage / 100).toStringAsFixed(2)}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'protected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // SECTION: Overview
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Overview', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.countActivePolicies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.shield_outlined,
                      title: 'Policies coming soon',
                      description: 'Your insurance policies will appear here',
                    ),
                  );
                }
                final count = snapshot.data!;
                if (count == 0) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.policy_outlined,
                      title: 'No policies recorded yet',
                      description: 'Add your first policy to see insights here.',
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
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Policies',
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

            // SECTION: Cost Analysis
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Cost Analysis', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadPoliciesMonthlyTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.payments_outlined,
                      title: 'Premium data loading',
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
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Premium',
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
            const SizedBox(height: Spacing.md), // Bottom padding
          ],
        ),
      ),
    );
  }
}
