// F2.1 STATUS: FIXED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_entry_bottom_sheet.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6FB),
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: const Color(0xFF1E6FD9),
            tooltip: 'Add to Ledger',
            onPressed: () => _showAddToLedgerSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar already accounts for status bar padding.
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
                    return const PrimaryCard(
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
                    return const AppCard(
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
                    return const AppCard(
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
                    return const AppCard(
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
      ),
    );
  }

  void _showAddToLedgerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _AddToLedgerBottomSheet(),
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

class _AddToLedgerBottomSheet extends StatelessWidget {
  const _AddToLedgerBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: Spacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Text(
                'Add to Ledger',
                style: theme.textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Manual Entry',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Add bill, subscription, or policy',
                style: theme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualEntryScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.document_scanner_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Add Document',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Scan or upload a document',
                style: theme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDocumentScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }
}
