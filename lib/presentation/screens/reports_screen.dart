// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/reports_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';
import '../theme/spacing.dart';

/// Reports screen
///
/// Displays bill and subscription analytics using ReportsViewModel.
/// Pure presentation logic - no business rules, no calculations.
/// Uses visual hierarchy: PrimaryCard for total monthly costs (hero KPI).
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repository = ReportsRepository(db);
    final viewModel = ReportsViewModel(repository);
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Combined Monthly Total (PRIMARY KPI)
            FutureBuilder(
              future: Future.wait([
                viewModel.loadBillsMonthlyTotal(),
                viewModel.loadSubscriptionsMonthlyTotal(),
              ]),
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
                      icon: Icons.query_stats_outlined,
                      title: 'Total unavailable',
                      description: 'Your monthly total will appear shortly',
                    ),
                  );
                }
                final data = snapshot.data!;
                final billsTotal = data[0];
                final subsTotal = data[1];
                final grandTotal = billsTotal + subsTotal;
                
                if (grandTotal == 0) {
                  return PrimaryCard(
                    child: EmptyState(
                      icon: Icons.money_off_csred_outlined,
                      title: 'No data recorded yet',
                      description: 'Add bills or subscriptions to see insights',
                    ),
                  );
                }
                
                return PrimaryCard(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '£${(grandTotal / 100).toStringAsFixed(2)}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'bills + subscriptions per month',
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

            // SECTION: Bills
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Bills', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadBillsMonthlyTotal(),
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
                      icon: Icons.receipt_long_outlined,
                      title: 'Bills data loading',
                      description: 'Your bill information will appear shortly',
                    ),
                  );
                }
                final total = snapshot.data!;
                if (total == 0) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.money_off_csred_outlined,
                      title: 'No bills recorded yet',
                      description: 'Add your first bill to see insights here.',
                    ),
                  );
                }
                return AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Total',
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

            // SECTION: Subscriptions
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Subscriptions', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadSubscriptionsMonthlyTotal(),
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
                      icon: Icons.subscriptions_outlined,
                      title: 'Subscriptions data loading',
                      description: 'Your subscription information will appear shortly',
                    ),
                  );
                }
                final total = snapshot.data!;
                if (total == 0) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.subscriptions_outlined,
                      title: 'No subscriptions recorded yet',
                      description: 'Add your first subscription to see insights here.',
                    ),
                  );
                }
                return AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.subscriptions,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Total',
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
