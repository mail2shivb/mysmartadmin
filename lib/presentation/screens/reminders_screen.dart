// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/reports/reports_repository.dart';
import '../viewmodels/reminders_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';
import '../theme/spacing.dart';

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
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
                        padding: EdgeInsets.all(Spacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return PrimaryCard(
                    child: EmptyState(
                      icon: Icons.pending_outlined,
                      title: 'Count unavailable',
                      iconSize: 40,
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
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          '$count',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'pending reminders',
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

            // SECTION: Upcoming
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Upcoming', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.loadRemindersDueSoon(daysAhead: 7),
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
                      icon: Icons.notifications_outlined,
                      title: 'Reminders coming soon',
                      description: 'Your upcoming reminders will appear here',
                    ),
                  );
                }
                final reminders = snapshot.data!;
                if (reminders.isEmpty) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'All clear',
                      description: 'No reminders due in the next 7 days',
                    ),
                  );
                }
                return Column(
                  children: reminders.map((reminder) {
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: Spacing.sm),
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
                              const SizedBox(width: Spacing.xs),
                              Expanded(
                                child: Text(
                                  reminder.title,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due: ${reminder.reminderDate.toLocal().toString().split(' ')[0]}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${reminder.daysUntilDue} days remaining • ${reminder.reminderType}',
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

            // SECTION: Overdue
            const SizedBox(height: Spacing.sectionHeaderTop),
            const SectionHeader(title: 'Overdue', addTopMargin: false),
            const SizedBox(height: Spacing.sectionHeaderBottom),
            FutureBuilder(
              future: viewModel.countOverdueReminders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppCard(
                    child: EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'Count unavailable',
                      iconSize: 32,
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
                        const SizedBox(height: Spacing.xs),
                        Text(
                          '$count',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: count > 0
                                ? theme.colorScheme.error
                                : null,
                          ),
                        ),
                        Text(
                          'overdue',
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
            const SizedBox(height: Spacing.md), // Bottom padding
          ],
        ),
      ),
    );
  }
}
