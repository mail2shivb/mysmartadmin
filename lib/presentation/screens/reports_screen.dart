// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/empty_state_widget.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/reports_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';

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

    return AppScaffold(
      useSafeArea: true,
      enableScroll: true,
      body: Padding(
        padding: AppPadding.screen,
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
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return PrimaryCard(
                    child: EmptyStateWidget(
                      icon: Icons.query_stats_outlined,
                      title: 'Your monthly picture is not available yet',
                      description:
                          'This screen helps you understand regular spending across bills and subscriptions, so you can see ongoing commitments more clearly.',
                    ),
                  );
                }
                final data = snapshot.data!;
                final billsTotal = data[0];
                final subsTotal = data[1];
                final grandTotal = billsTotal + subsTotal;
                
                if (grandTotal == 0) {
                  return PrimaryCard(
                    child: EmptyStateWidget(
                      icon: Icons.money_off_csred_outlined,
                      title: 'No regular spending to review yet',
                      description:
                          'Once bills or subscriptions are recorded, this screen will help you understand monthly patterns and recurring costs.',
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
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'tracked each month across bills and subscriptions',
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

            // SECTION: Bill Commitments
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Bill Commitments'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadBillsMonthlyTotal(),
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
                      icon: Icons.receipt_long_outlined,
                      title: 'Your bill summary is not available yet',
                      description:
                          'This section shows the monthly cost of tracked bills, so you can understand regular household outgoings.',
                    ),
                  );
                }
                final total = snapshot.data!;
                if (total == 0) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.money_off_csred_outlined,
                      title: 'No bills are being tracked yet',
                      description:
                          'When you start recording bills, this section will show their monthly total and help you monitor ongoing commitments.',
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
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tracked monthly total',
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

            // SECTION: Subscription Spend
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Subscription Spend'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadSubscriptionsMonthlyTotal(),
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
                      icon: Icons.subscriptions_outlined,
                      title: 'Your subscription summary is not available yet',
                      description:
                          'This section shows the monthly cost of subscriptions, so you can review recurring digital and service spending in one place.',
                    ),
                  );
                }
                final total = snapshot.data!;
                if (total == 0) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.subscriptions_outlined,
                      title: 'No subscriptions are being tracked yet',
                      description:
                          'When subscriptions are recorded, this section will help you see what they cost each month and what may be worth reviewing.',
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
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tracked monthly total',
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
