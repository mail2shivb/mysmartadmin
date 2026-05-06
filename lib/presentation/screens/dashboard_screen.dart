// B4.3 STATUS: IMPLEMENTED
// F2.1 STATUS: FIXED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/empty_state_widget.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';

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

    return AppScaffold(
      useSafeArea: true,
      enableScroll: true,
      body: Padding(
        padding: AppPadding.screen,
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
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const PrimaryCard(
                    child: EmptyStateWidget(
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
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'estimated each month',
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

            // SECTION: Monthly Commitments
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(title: 'Monthly Commitments'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadMonthlyCostSummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.query_stats_outlined,
                      title: 'Your monthly summary is not ready yet',
                      description:
                          'This section brings together bills, subscriptions, and policies so you can quickly understand your regular commitments.',
                    ),
                  );
                }
                final summary = snapshot.data!;
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCostRow(context, 'Bills', summary.billsTotal),
                      const SizedBox(height: AppSpacing.xs),
                      _buildCostRow(context, 'Subscriptions', summary.subscriptionsTotal),
                      const SizedBox(height: AppSpacing.xs),
                      _buildCostRow(context, 'Policies', summary.policiesTotal),
                      const Divider(height: AppSpacing.md),
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

            // SECTION: What You’re Tracking
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'What You’re Tracking'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadActiveEntitiesSummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'Your tracked items are not available yet',
                      description:
                          'This area shows how many active records you already have across bills, subscriptions, policies, and documents.',
                    ),
                  );
                }
                final summary = snapshot.data!;
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCountRow(context, Icons.receipt_long, 'Bills', summary.activeBills),
                      const SizedBox(height: AppSpacing.xs),
                      _buildCountRow(context, Icons.subscriptions, 'Subscriptions', summary.activeSubscriptions),
                      const SizedBox(height: AppSpacing.xs),
                      _buildCountRow(context, Icons.shield, 'Policies', summary.activePolicies),
                      const SizedBox(height: AppSpacing.xs),
                      _buildCountRow(context, Icons.description, 'Documents', summary.activeDocuments),
                    ],
                  ),
                );
              },
            ),

            // SECTION: Upcoming Attention
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Upcoming Attention'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadActiveEntitiesSummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.notifications_outlined,
                      title: 'Your reminder overview is not available yet',
                      description:
                          'This section highlights the reminders that matter next, so you can see pending actions at a glance.',
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
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending reminders',
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

            const SizedBox(height: AppSpacing.md), // Bottom padding
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
        const SizedBox(width: AppSpacing.xs),
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
