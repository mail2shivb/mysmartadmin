import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../domain/reports/reports_repository.dart';
import '../../domain/reports/dto/active_entity_summary.dart';
import '../../presentation/viewmodels/dashboard_view_model.dart';
import '../../presentation/viewmodels/reports_view_model.dart';
import '../../shared/widgets/l_widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repo = ReportsRepository(db);
    final dashVm = DashboardViewModel(repo);
    final repVm = ReportsViewModel(repo);

    return LScreen(
      title: 'Reports',
      subtitle: 'Insights across your vault',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // ── Overview stats ─────────────────────────────────────────
          const SectionTitle('Overview'),
          FutureBuilder<ActiveEntitySummary>(
            future: dashVm.loadActiveEntitiesSummary(),
            builder: (context, snap) {
              final s = snap.data;
              final total = (s?.activeBills ?? 0) +
                  (s?.activePolicies ?? 0) +
                  (s?.activeDocuments ?? 0) +
                  (s?.activeSubscriptions ?? 0);
              return Row(
                children: [
                  StatCard(
                    value: '$total',
                    label: 'Records',
                    color: AppColors.royalPurple,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    value: '${s?.activeBills ?? 0}',
                    label: 'Bills',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    value: '${s?.activePolicies ?? 0}',
                    label: 'Policies',
                    color: AppColors.info,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Monthly total ──────────────────────────────────────────
          const SectionTitle('Monthly commitment'),
          FutureBuilder<List<int>>(
            future: Future.wait([
              repVm.loadBillsMonthlyTotal(),
              repVm.loadSubscriptionsMonthlyTotal(),
            ]),
            builder: (context, snap) {
              final bills = snap.data?[0] ?? 0;
              final subs = snap.data?[1] ?? 0;
              final total = (bills + subs) / 100.0;
              return LCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '£${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniStat(
                          label: 'Bills',
                          value:
                              '£${(bills / 100).toStringAsFixed(2)}',
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        _MiniStat(
                          label: 'Subscriptions',
                          value:
                              '£${(subs / 100).toStringAsFixed(2)}',
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Report categories ──────────────────────────────────────
          const SectionTitle('Reports'),
          LCard(
            padding: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 4),
            child: Column(
              children: [
                ListRow(
                  icon: Icons.bar_chart_rounded,
                  title: 'Monthly bills',
                  subtitle: 'Breakdown of recurring bill costs',
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.event_note_outlined,
                  title: 'Renewals in 90 days',
                  subtitle: 'All upcoming renewal dates',
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.timeline_outlined,
                  title: 'Life timeline',
                  subtitle: 'Key dates across all your records',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Bills due soon ─────────────────────────────────────────
          const SectionTitle('Bills due soon'),
          FutureBuilder<List<BillEntity>>(
            future: repVm.loadBillsDueSoon(daysAhead: 30),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryPurple,
                        strokeWidth: 2),
                  ),
                );
              }
              final bills = snap.data ?? [];
              if (bills.isEmpty) {
                return const LEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'No bills due soon',
                  message: 'Nothing due in the next 30 days.',
                );
              }
              return LCard(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 4),
                child: Column(
                  children: [
                    for (int i = 0; i < bills.length; i++) ...[
                      if (i > 0)
                        const Divider(
                            height: 1, color: AppColors.divider),
                      ListRow(
                        icon: Icons.receipt_long_outlined,
                        title: bills[i].name,
                        subtitle: bills[i].nextDueDate != null
                            ? 'Due ${_formatDate(bills[i].nextDueDate!)}'
                            : null,
                        trailing: Text(
                          '£${(bills[i].amountCents / 100).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
