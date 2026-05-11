import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../domain/reports/reports_repository.dart';
import '../../presentation/viewmodels/reminders_view_model.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';
import '../../shared/widgets/proto_empty_state.dart';

/// Reminders screen — prototype RemindersTasksPage style wired to live data.
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repo = ReportsRepository(db);
    final vm = RemindersViewModel(repo);

    return PageScaffold(
      title: 'Reminders',
      subtitle: 'Renewals, deadlines and tasks',
      actions: [
        IconButton(
          icon: const Icon(Icons.task_alt_rounded, color: Colors.white),
          tooltip: 'Tasks',
          onPressed: () => context.go(AppRouter.tasks),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(ProtoSpacing.lg),
        children: [
          // ── Pending count hero ─────────────────────────────────────────
          FutureBuilder<int>(
            future: vm.countPendingReminders(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return ProtoAppCard(
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.paleLavender,
                        borderRadius: BorderRadius.circular(ProtoRadius.md),
                      ),
                      child: const Icon(Icons.notifications_active_rounded,
                          color: AppColors.primaryPurple, size: 28),
                    ),
                    const SizedBox(width: ProtoSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$count',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primaryPurple,
                            )),
                        const Text('pending reminders',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Due soon ───────────────────────────────────────────────────
          Text('Due Soon', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          FutureBuilder(
            future: vm.loadRemindersDueSoon(daysAhead: 7),
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
              final reminders = snap.data ?? [];
              if (reminders.isEmpty) {
                return const ProtoAppCard(
                  child: ProtoEmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'Nothing due soon',
                    message: 'No reminders due in the next 7 days.',
                  ),
                );
              }
              return Column(
                children: reminders.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: ProtoSpacing.sm),
                  child: ProtoAppCard(
                    padding: const EdgeInsets.all(ProtoSpacing.md),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: r.daysUntilDue <= 3
                              ? const Color(0xFFFFE0DC)
                              : AppColors.tileAmber,
                          borderRadius:
                              BorderRadius.circular(ProtoRadius.md),
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: r.daysUntilDue <= 3
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                      ),
                      title: Text(r.triggerTypeId,
                          style: AppTextStyles.title.copyWith(fontSize: 15)),
                      subtitle: Text(
                        'Due ${r.firesAt.toLocal().toString().split(' ')[0]}'
                        ' · ${r.daysUntilDue}d left',
                        style: AppTextStyles.bodySecondary,
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                    ),
                  ),
                )).toList(),
              );
            },
          ),

          const SizedBox(height: ProtoSpacing.lg),

          // ── Needs attention ────────────────────────────────────────────
          Text('Needs Attention', style: AppTextStyles.title),
          const SizedBox(height: ProtoSpacing.sm),
          FutureBuilder<int>(
            future: vm.countOverdueReminders(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return ProtoAppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? const Color(0xFFFFE0DC)
                            : AppColors.softLavender,
                        borderRadius: BorderRadius.circular(ProtoRadius.md),
                      ),
                      child: Icon(Icons.event_busy_rounded,
                          color: count > 0
                              ? AppColors.error
                              : AppColors.textMuted),
                    ),
                    const SizedBox(width: ProtoSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$count',
                            style: AppTextStyles.headline.copyWith(
                              color: count > 0
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                            )),
                        const Text('overdue reminders',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
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
