// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/empty_state_widget.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/reminders_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';

/// Reminders screen
///
/// Displays reminder data using RemindersViewModel.
/// Pure presentation logic - no business rules, no calculations.
/// Uses visual hierarchy: PrimaryCard for pending reminder count (hero KPI).
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final repository = ReportsRepository(db);
    final viewModel = RemindersViewModel(repository);
    final theme = Theme.of(context);

    return AppScaffold(
      useSafeArea: true,
      enableScroll: true,
      body: Padding(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Count (PRIMARY KPI)
            FutureBuilder(
              future: viewModel.countPendingReminders(),
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
                      icon: Icons.pending_outlined,
                      title: 'Count unavailable',
                      description: 'Your reminder count will appear shortly',
                    ),
                  );
                }
                final count = snapshot.data!;
                return PrimaryCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 44,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$count',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'pending reminders',
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

            // SECTION: Due Soon
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Due Soon'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.loadRemindersDueSoon(daysAhead: 7),
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
                      icon: Icons.notifications_outlined,
                      title: 'Your due-soon reminders are not available yet',
                      description:
                          'This list highlights reminders generated from expiry, renewal, and review dates, so you can act before something becomes urgent.',
                    ),
                  );
                }
                final reminders = snapshot.data!;
                if (reminders.isEmpty) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.check_circle_outline,
                      title: 'Nothing is due soon',
                      description:
                          'You have no reminders due in the next 7 days. When important dates approach, they will appear here automatically.',
                    ),
                  );
                }
                return Column(
                  children: reminders.map((reminder) {
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  reminder.triggerTypeId,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due on ${reminder.firesAt.toLocal().toString().split(' ')[0]}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${reminder.daysUntilDue} days left • ${reminder.triggerTypeId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // SECTION: Needs Attention
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(title: 'Needs Attention'),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: viewModel.countOverdueReminders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppCard(
                    child: EmptyStateWidget(
                      icon: Icons.event_busy_outlined,
                      title: 'Your overdue view is not available yet',
                      description:
                          'This area helps you spot reminders that may need immediate action, based on dates already stored in your records.',
                    ),
                  );
                }
                final count = snapshot.data!;
                return AppCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 32,
                          color: count > 0
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '$count',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: count > 0
                                ? theme.colorScheme.error
                                : null,
                          ),
                        ),
                        Text(
                          'overdue reminders',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
