import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../domain/reports/reports_repository.dart';
import '../../presentation/viewmodels/dashboard_view_model.dart';
import '../../shared/widgets/colourful_icon_tile.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';
import '../../shared/widgets/proto_empty_state.dart';

/// Dashboard — prototype HomeDashboardPage style wired to real Drift data.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repository = ReportsRepository(db);
    final viewModel = DashboardViewModel(repository);

    return PageScaffold(
      title: 'Dashboard',
      subtitle: 'Your life-admin at a glance',
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          tooltip: 'Search',
          onPressed: () => context.go(AppRouter.search),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: 'Settings',
          onPressed: () => context.go(AppRouter.settings),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(ProtoSpacing.lg),
        children: [
          // ── Hero: monthly total ─────────────────────────────────────────
          FutureBuilder<int>(
            future: viewModel.loadTotalMonthlyCommitments(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const ProtoAppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(ProtoSpacing.xxxl),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                );
              }
              final total = (snap.data ?? 0) / 100.0;
              return ProtoAppCard(
                child: Column(
                  children: [
                    Text(
                      '£${total.toStringAsFixed(2)}',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: 48,
                        color: AppColors.primaryPurple,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('estimated each month',
                        style: AppTextStyles.bodySecondary),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Quick access grid ──────────────────────────────────────────
          Text('Quick access', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: ProtoSpacing.sm,
            crossAxisSpacing: ProtoSpacing.sm,
            childAspectRatio: 1,
            children: [
              ColourfulIconTile(
                icon: Icons.lock_rounded, label: 'Vault',
                tint: AppColors.paleLavender,
                onTap: () => context.go(AppRouter.vault),
              ),
              ColourfulIconTile(
                icon: Icons.description_rounded, label: 'Documents',
                tint: AppColors.tileBlue,
                onTap: () => context.go(AppRouter.documents),
              ),
              ColourfulIconTile(
                icon: Icons.receipt_long_rounded, label: 'Bills',
                tint: AppColors.tileGreen,
                onTap: () => context.go(AppRouter.bills),
              ),
              ColourfulIconTile(
                icon: Icons.notifications_rounded, label: 'Reminders',
                tint: AppColors.tileAmber,
                onTap: () => context.go(AppRouter.reminders),
              ),
              ColourfulIconTile(
                icon: Icons.search_rounded, label: 'Search',
                tint: AppColors.tileIndigo,
                onTap: () => context.go(AppRouter.search),
              ),
              ColourfulIconTile(
                icon: Icons.bar_chart_rounded, label: 'Reports',
                tint: AppColors.tileSlate,
                onTap: () => context.go(AppRouter.reports),
              ),
            ],
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Monthly commitments ────────────────────────────────────────
          Text('Monthly Commitments', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          FutureBuilder(
            future: viewModel.loadMonthlyCostSummary(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const ProtoAppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(ProtoSpacing.xl),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPurple),
                    ),
                  ),
                );
              }
              if (snap.hasError || snap.data == null) {
                return const ProtoAppCard(
                  child: ProtoEmptyState(
                    icon: Icons.query_stats_outlined,
                    title: 'Monthly summary not ready',
                    message: 'Add some bills to see your monthly total.',
                  ),
                );
              }
              final s = snap.data!;
              return ProtoAppCard(
                padding: const EdgeInsets.all(ProtoSpacing.lg),
                child: Column(
                  children: [
                    _CostRow('Bills', s.billsTotal),
                    const SizedBox(height: ProtoSpacing.xs),
                    _CostRow('Subscriptions', s.subscriptionsTotal),
                    const SizedBox(height: ProtoSpacing.xs),
                    _CostRow('Policies', s.policiesTotal),
                    const Divider(height: ProtoSpacing.lg, color: AppColors.divider),
                    _CostRow('Total', s.grandTotal, bold: true),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── What you're tracking ───────────────────────────────────────
          Text("What You're Tracking", style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          FutureBuilder(
            future: viewModel.loadActiveEntitiesSummary(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const ProtoAppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(ProtoSpacing.xl),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPurple),
                    ),
                  ),
                );
              }
              final s = snap.data;
              return ProtoAppCard(
                padding: const EdgeInsets.all(ProtoSpacing.lg),
                child: Column(
                  children: [
                    _CountRow(Icons.receipt_long_rounded, 'Bills',
                        s?.activeBills ?? 0),
                    const SizedBox(height: ProtoSpacing.xs),
                    _CountRow(Icons.subscriptions_rounded, 'Subscriptions',
                        s?.activeSubscriptions ?? 0),
                    const SizedBox(height: ProtoSpacing.xs),
                    _CountRow(Icons.shield_rounded, 'Policies',
                        s?.activePolicies ?? 0),
                    const SizedBox(height: ProtoSpacing.xs),
                    _CountRow(Icons.description_rounded, 'Documents',
                        s?.activeDocuments ?? 0),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.xxxl),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final int cents;
  final bool bold;
  const _CostRow(this.label, this.cents, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.body;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('£${(cents / 100).toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const _CountRow(this.icon, this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryPurple),
        const SizedBox(width: ProtoSpacing.sm),
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(
          '$count',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
