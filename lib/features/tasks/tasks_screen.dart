import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/empty_state_widget.dart';

/// Tasks screen
/// 
/// Shows:
/// - System-generated tasks (e.g., "Renew passport")
/// - User-created tasks
/// - Document-linked alerts
/// - Expiry reminders
/// 
/// Task sources:
/// - Expiry dates from documents
/// - Renewal reminders
/// - Review reminders
/// - Manual user tasks
/// 
/// AppBar includes settings icon
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter tasks
            },
            tooltip: 'Filter tasks',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouter.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      padding: AppPadding.screen,
      body: const EmptyStateWidget(
        icon: Icons.task_alt,
        title: 'Nothing needs your attention yet',
        description:
            'Tasks are created from important dates such as expiry, renewal, and review points, so you can see what needs action in one place. You can also add a manual task for anything you want to track yourself.',
        primaryButtonLabel: 'Create Manual Task',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create manual task
        },
        tooltip: 'Create Manual Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
