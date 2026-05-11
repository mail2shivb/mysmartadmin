import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../domain/reports/reports_repository.dart';
import '../../domain/reports/dto/active_entity_summary.dart';
import '../../domain/reports/dto/upcoming_reminder_view.dart';
import '../../presentation/viewmodels/dashboard_view_model.dart';
import '../../presentation/viewmodels/reminders_view_model.dart';
import '../../shared/widgets/l_widgets.dart';

const _kCategories = <({String label, IconData icon, String id})>[
  (label: 'Identity',      icon: Icons.badge_outlined,            id: 'identity_legal'),
  (label: 'Insurance',     icon: Icons.shield_outlined,           id: 'insurance_protection'),
  (label: 'Banking',       icon: Icons.account_balance_outlined,  id: 'banking_credit_borrowing'),
  (label: 'Utilities',     icon: Icons.bolt_outlined,             id: 'bills_utilities_subscriptions'),
  (label: 'Vehicle',       icon: Icons.directions_car_outlined,   id: 'vehicles_transport'),
  (label: 'Home',          icon: Icons.home_outlined,             id: 'home_property'),
  (label: 'Work',          icon: Icons.work_outline,              id: 'work_income_tax'),
  (label: 'Subscriptions', icon: Icons.subscriptions_outlined,    id: 'bills_utilities_subscriptions'),
];

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const _HomeDashboardScreenReal();
}

class _HomeDashboardScreenReal extends StatelessWidget {
  const _HomeDashboardScreenReal();

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repo = ReportsRepository(db);
    final dashVm = DashboardViewModel(repo);
    final remVm = RemindersViewModel(repo);

    return LScreen(
      title: 'LedgerAI',
      subtitle: 'Your life admin, privately on this device',
      searchHint: 'Search records, reminders, tasks…',
      onSearchTap: () => context.go(AppRouter.search),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () => context.go(AppRouter.reminders),
          ),
          const SizedBox(width: 8),
          HeaderIcon(
            icon: Icons.settings_outlined,
            onTap: () => context.go(AppRouter.settings),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // ── Categories ─────────────────────────────────────────────────
          const SectionTitle('Categories'),
          CategoryCarousel(
            items: _kCategories,
            onTap: (id) => context.go('/vault/category/$id'),
          ),
          const SizedBox(height: 20),

          // ── Action needed ──────────────────────────────────────────────
          const SectionTitle('Action needed'),
          FutureBuilder<List<UpcomingReminderView>>(
            future: remVm.loadRemindersDueSoon(daysAhead: 30),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const _LoadingCard();
              }
              final reminders = snap.data ?? [];
              if (reminders.isEmpty) {
                return const LEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'All clear',
                  message: 'No upcoming deadlines in the next 30 days.',
                );
              }
              return LCard(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 4),
                child: Column(
                  children: [
                    for (int i = 0;
                        i < reminders.length && i < 4;
                        i++) ...[
                      if (i > 0)
                        const Divider(
                            height: 1, color: AppColors.divider),
                      ListRow(
                        icon: _iconForKind(
                            reminders[i].sourceEntityKind),
                        title: _formatTrigger(
                            reminders[i].triggerTypeId),
                        subtitle:
                            '${_labelKind(reminders[i].sourceEntityKind)}'
                            ' · Due in ${reminders[i].daysUntilDue}d',
                        badge: StatusBadge(
                          kind: _badgeForDays(
                              reminders[i].daysUntilDue),
                          label: reminders[i].daysUntilDue <= 0
                              ? 'Today'
                              : reminders[i].daysUntilDue <= 3
                                  ? 'Urgent'
                                  : reminders[i].daysUntilDue <= 14
                                      ? 'Soon'
                                      : 'Upcoming',
                        ),
                        onTap: () =>
                            context.go(AppRouter.reminders),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Monthly commitment ─────────────────────────────────────────
          const SectionTitle('Monthly commitment'),
          FutureBuilder<int>(
            future: dashVm.loadTotalMonthlyCommitments(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const _LoadingCard();
              }
              final total = (snap.data ?? 0) / 100.0;
              return LCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.paleLavender,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.currency_pound,
                          color: AppColors.royalPurple, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '£${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.royalPurple,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'estimated each month',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── What you're tracking ───────────────────────────────────────
          const SectionTitle("What you're tracking"),
          FutureBuilder<ActiveEntitySummary>(
            future: dashVm.loadActiveEntitiesSummary(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const _LoadingCard();
              }
              final s = snap.data;
              return LCard(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 4),
                child: Column(
                  children: [
                    ListRow(
                      icon: Icons.receipt_long_outlined,
                      title: 'Bills',
                      subtitle: '${s?.activeBills ?? 0} active',
                      trailing: Text(
                        '${s?.activeBills ?? 0}',
                        style: const TextStyle(
                          color: AppColors.royalPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => context.go(AppRouter.vault),
                    ),
                    const Divider(
                        height: 1, color: AppColors.divider),
                    ListRow(
                      icon: Icons.shield_outlined,
                      title: 'Policies',
                      subtitle: '${s?.activePolicies ?? 0} active',
                      trailing: Text(
                        '${s?.activePolicies ?? 0}',
                        style: const TextStyle(
                          color: AppColors.royalPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => context.go(AppRouter.vault),
                    ),
                    const Divider(
                        height: 1, color: AppColors.divider),
                    ListRow(
                      icon: Icons.description_outlined,
                      title: 'Documents',
                      subtitle: '${s?.activeDocuments ?? 0} saved',
                      trailing: Text(
                        '${s?.activeDocuments ?? 0}',
                        style: const TextStyle(
                          color: AppColors.royalPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () =>
                          context.go(AppRouter.documents),
                    ),
                    const Divider(
                        height: 1, color: AppColors.divider),
                    ListRow(
                      icon: Icons.subscriptions_outlined,
                      title: 'Subscriptions',
                      subtitle: '${s?.activeSubscriptions ?? 0} active',
                      trailing: Text(
                        '${s?.activeSubscriptions ?? 0}',
                        style: const TextStyle(
                          color: AppColors.royalPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => context.go(AppRouter.vault),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Quick actions ──────────────────────────────────────────────
          const SectionTitle('Quick actions'),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.lock_outline_rounded,
                  label: 'Open Vault',
                  onTap: () => context.go(AppRouter.vault),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  onTap: () => context.go(AppRouter.reports),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

IconData _iconForKind(String kind) => switch (kind) {
      'bill' => Icons.receipt_long_outlined,
      'policy' => Icons.shield_outlined,
      'document' => Icons.badge_outlined,
      'subscription' => Icons.subscriptions_outlined,
      'vehicle' => Icons.directions_car_outlined,
      'property' => Icons.home_outlined,
      _ => Icons.description_outlined,
    };

String _labelKind(String kind) => switch (kind) {
      'bill' => 'Bill',
      'policy' => 'Policy',
      'document' => 'Document',
      'subscription' => 'Subscription',
      'vehicle' => 'Vehicle',
      'property' => 'Property',
      _ => kind,
    };

String _formatTrigger(String id) => switch (id) {
      'expiry_date' => 'Expires soon',
      'renewal_date' => 'Renewal due',
      'payment_due_date' => 'Payment due',
      'review_date' => 'Review needed',
      'service_due_date' => 'Service due',
      'contract_end_date' => 'Contract ending',
      'trial_end_date' => 'Trial ending',
      'statement_available_date' => 'Statement available',
      _ => id.replaceAll('_', ' '),
    };

BadgeKind _badgeForDays(int days) {
  if (days <= 0) return BadgeKind.urgent;
  if (days <= 7) return BadgeKind.expiring;
  if (days <= 14) return BadgeKind.review;
  return BadgeKind.info;
}

// ── Private widgets ────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const LCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
              color: AppColors.primaryPurple, strokeWidth: 2),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.paleLavender,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.royalPurple, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.deepPurple,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
