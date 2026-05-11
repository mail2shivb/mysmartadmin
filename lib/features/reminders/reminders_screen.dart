import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../domain/reports/reports_repository.dart';
import '../../domain/reports/dto/upcoming_reminder_view.dart';
import '../../presentation/viewmodels/reminders_view_model.dart';
import '../../shared/widgets/l_widgets.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _filter = 'All';
  late final RemindersViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RemindersViewModel(ReportsRepository(DatabaseProvider.instance));
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Reminders',
      subtitle: 'Renewals, deadlines and bills',
      searchHint: 'Search reminders…',
      child: FutureBuilder<List<UpcomingReminderView>>(
        future: _vm.loadRemindersDueSoon(daysAhead: 90),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                    color: AppColors.primaryPurple, strokeWidth: 2),
              ),
            );
          }
          final all = snap.data ?? [];
          return _RemindersBody(
            reminders: all,
            filter: _filter,
            onFilterChange: (f) => setState(() => _filter = f),
          );
        },
      ),
    );
  }
}

class _RemindersBody extends StatelessWidget {
  final List<UpcomingReminderView> reminders;
  final String filter;
  final ValueChanged<String> onFilterChange;

  const _RemindersBody({
    required this.reminders,
    required this.filter,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    // Group reminders: today / this week / later
    final today = reminders
        .where((r) => r.daysUntilDue <= 0)
        .toList();
    final thisWeek = reminders
        .where((r) => r.daysUntilDue >= 1 && r.daysUntilDue <= 7)
        .toList();
    final later = reminders
        .where((r) => r.daysUntilDue > 7)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // ── Filter chips ─────────────────────────────────────────────
        FilterChipRow(
          chips: const ['All', 'Bills', 'Renewals', 'Tasks', 'Overdue'],
          active: filter,
          onChange: onFilterChange,
        ),
        const SizedBox(height: 20),

        if (reminders.isEmpty) ...[
          const LEmptyState(
            icon: Icons.check_circle_outline,
            title: 'All clear',
            message: 'No upcoming reminders. You are on top of everything.',
          ),
        ] else ...[
          // ── Today ─────────────────────────────────────────────────
          if (today.isNotEmpty) ...[
            const SectionTitle('Today'),
            LCard(
              padding: const EdgeInsets.symmetric(
                  vertical: 4, horizontal: 4),
              child: Column(
                children: _buildRows(context, today),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── This week ─────────────────────────────────────────────
          if (thisWeek.isNotEmpty) ...[
            const SectionTitle('This week'),
            LCard(
              padding: const EdgeInsets.symmetric(
                  vertical: 4, horizontal: 4),
              child: Column(
                children: _buildRows(context, thisWeek),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Later ─────────────────────────────────────────────────
          if (later.isNotEmpty) ...[
            const SectionTitle('Later'),
            LCard(
              padding: const EdgeInsets.symmetric(
                  vertical: 4, horizontal: 4),
              child: Column(
                children: _buildRows(context, later),
              ),
            ),
          ],
        ],
      ],
    );
  }

  List<Widget> _buildRows(
      BuildContext context, List<UpcomingReminderView> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        rows.add(
            const Divider(height: 1, color: AppColors.divider));
      }
      final r = items[i];
      rows.add(ListRow(
        icon: _iconForKind(r.sourceEntityKind),
        title: _formatTrigger(r.triggerTypeId),
        subtitle: r.daysUntilDue <= 0
            ? '${_labelKind(r.sourceEntityKind)} · Due today'
            : '${_labelKind(r.sourceEntityKind)} · Due in ${r.daysUntilDue}d',
        badge: StatusBadge(
          kind: _badgeForDays(r.daysUntilDue),
          label: r.daysUntilDue <= 0
              ? 'Today'
              : r.daysUntilDue <= 3
                  ? 'Urgent'
                  : r.daysUntilDue <= 7
                      ? 'Soon'
                      : 'Later',
        ),
        onTap: () {},
      ));
    }
    return rows;
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
      _ => Icons.notifications_outlined,
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
