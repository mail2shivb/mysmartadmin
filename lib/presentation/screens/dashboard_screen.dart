// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';
import '../theme/spacing.dart';

/// Dashboard screen
///
/// Displays aggregated financial data using DashboardViewModel.
/// Pure presentation logic - no business rules, no calculations.
/// 
/// Hierarchy:
/// 1. Hero: Total Commitments (no header, immediate impact)
/// 2. Section: Monthly Overview
/// 3. Section: Active Items
/// 4. Section: Reminders Summary
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repository = ReportsRepository(db);
    final viewModel = DashboardViewModel(repository);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO: Total Monthly Commitments (NO HEADER)
            FutureBuilder(
              future: viewModel.loadTotalMonthlyCommitments(),
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
                      icon: Icons.account_balance_outlined,
                      title: 'Commitments loading',
                      description: 'Your monthly total will appear shortly',
                    ),
                  );
                }
                final total = snapshot.data!;
                final theme = Theme.of(context);
                return PrimaryCard(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '£${(total / 100).toStringAsFixed(2)}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'per month',
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

            // SECTION: Monthly Overview
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Monthly Overview', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadMonthlyCostSummary(),
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
                      icon: Icons.query_stats_outlined,
                      title: 'Cost summary unavailable',
                      description: 'Your monthly costs will appear here',
                    ),
                  );
                }
                final summary = snapshot.data!;
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCostRow(context, 'Bills', summary.billsTotal),
                      const SizedBox(height: Spacing.xs),
                      _buildCostRow(context, 'Subscriptions', summary.subscriptionsTotal),
                      const SizedBox(height: Spacing.xs),
                      _buildCostRow(context, 'Policies', summary.policiesTotal),
                      const Divider(height: Spacing.md),
                      _buildCostRow(
                        context,
                        'Total',
                        summary.grandTotal,
                        isBold: true,
                      ),
                    ],
                  ),
                );
              },
            ),

            // SECTION: Active Items
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Active Items', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadActiveEntitiesSummary(),
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
                      icon: Icons.inventory_2_outlined,
                      title: 'Summary coming soon',
                      description: 'Your active items will be counted here',
                    ),
                  );
                }
                final summary = snapshot.data!;
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCountRow(context, Icons.receipt_long, 'Bills', summary.activeBills),
                      const SizedBox(height: Spacing.xs),
                      _buildCountRow(context, Icons.subscriptions, 'Subscriptions', summary.activeSubscriptions),
                      const SizedBox(height: Spacing.xs),
                      _buildCountRow(context, Icons.shield, 'Policies', summary.activePolicies),
                      const SizedBox(height: Spacing.xs),
                      _buildCountRow(context, Icons.description, 'Documents', summary.activeDocuments),
                    ],
                  ),
                );
              },
            ),

            // SECTION: Reminders Summary
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Reminders Summary', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadActiveEntitiesSummary(),
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
                      icon: Icons.notifications_outlined,
                      title: 'Reminders unavailable',
                      description: 'Your reminders will appear here',
                    ),
                  );
                }
                final summary = snapshot.data!;
                final theme = Theme.of(context);
                return AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Reminders',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${summary.pendingReminders}',
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

  Widget _buildCostRow(BuildContext context, String label, int amountCents, {bool isBold = false}) {
    final theme = Theme.of(context);
    final textStyle = isBold
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          '£${(amountCents / 100).toStringAsFixed(2)}',
          style: textStyle,
        ),
      ],
    );
  }

  Widget _buildCountRow(BuildContext context, IconData icon, String label, int count) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          '$count',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
