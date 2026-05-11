import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../data/local/app_database.dart';
import '../../domain/reports/reports_repository.dart';
import '../../presentation/viewmodels/reports_view_model.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';
import '../../shared/widgets/proto_empty_state.dart';

/// Reports screen — prototype PageScaffold style, wired to real Drift data.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repository = ReportsRepository(db);
    final viewModel = ReportsViewModel(repository);

    return PageScaffold(
      title: 'Reports',
      subtitle: 'Insights from your private vault',
      child: ListView(
        padding: const EdgeInsets.all(ProtoSpacing.lg),
        children: [
          // ── Monthly total hero ─────────────────────────────────────────
          FutureBuilder(
            future: Future.wait([
              viewModel.loadBillsMonthlyTotal(),
              viewModel.loadSubscriptionsMonthlyTotal(),
            ]),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const ProtoAppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(ProtoSpacing.xxxl),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPurple),
                    ),
                  ),
                );
              }
              final bills = snap.data?[0] ?? 0;
              final subs  = snap.data?[1] ?? 0;
              final total = (bills + subs) / 100.0;
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
                    const Text(
                      'tracked each month across bills & subscriptions',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Report tiles ───────────────────────────────────────────────
          Text('Report categories', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),

          _ReportTile(
            icon: Icons.receipt_long_rounded,
            tint: AppColors.tileGreen,
            title: 'Bill Commitments',
            subtitle: 'Monthly total across all tracked bills',
            future: viewModel.loadBillsMonthlyTotal(),
          ),
          const SizedBox(height: ProtoSpacing.sm),
          _ReportTile(
            icon: Icons.subscriptions_rounded,
            tint: AppColors.tileIndigo,
            title: 'Subscription Spend',
            subtitle: 'Monthly cost of active subscriptions',
            future: viewModel.loadSubscriptionsMonthlyTotal(),
          ),
          const SizedBox(height: ProtoSpacing.sm),

          // ── Bills due soon ─────────────────────────────────────────────
          Text('Bills due soon', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          FutureBuilder<List<BillEntity>>(
            future: viewModel.loadBillsDueSoon(daysAhead: 30),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(ProtoSpacing.xl),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryPurple),
                  ),
                );
              }
              final bills = snap.data ?? [];
              if (bills.isEmpty) {
                return const ProtoAppCard(
                  child: ProtoEmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'No bills due in 30 days',
                    message: 'You are all caught up.',
                  ),
                );
              }
              return Column(
                children: bills.map((bill) {
                  final daysLeft = bill.nextDueDate != null
                      ? bill.nextDueDate!
                          .difference(DateTime.now())
                          .inDays
                      : null;
                  final urgentColor = (daysLeft != null && daysLeft <= 7)
                      ? AppColors.error
                      : AppColors.warning;
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: ProtoSpacing.sm),
                    child: ProtoAppCard(
                      padding: const EdgeInsets.all(ProtoSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE0DC),
                              borderRadius:
                                  BorderRadius.circular(ProtoRadius.md),
                            ),
                            child: Icon(Icons.receipt_long_rounded,
                                color: urgentColor, size: 20),
                          ),
                          const SizedBox(width: ProtoSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bill.name,
                                    style: AppTextStyles.title
                                        .copyWith(fontSize: 15)),
                                if (daysLeft != null)
                                  Text(
                                    daysLeft <= 0
                                        ? 'Due today'
                                        : '$daysLeft days left',
                                    style: AppTextStyles.bodySecondary
                                        .copyWith(color: urgentColor),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '£${(bill.amountCents / 100).toStringAsFixed(2)}',
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.primaryPurple,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.xxxl),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final Future<int> future;

  const _ReportTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return ProtoAppCard(
      padding: const EdgeInsets.all(ProtoSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(ProtoRadius.md),
            ),
            child: Icon(icon, color: AppColors.deepPurple, size: 22),
          ),
          const SizedBox(width: ProtoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.title.copyWith(fontSize: 15)),
                Text(subtitle, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          FutureBuilder<int>(
            future: future,
            builder: (_, snap) {
              final val = snap.data ?? 0;
              return Text(
                '£${(val / 100).toStringAsFixed(2)}',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.primaryPurple,
                  fontSize: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
