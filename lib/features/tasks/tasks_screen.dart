import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/utils/constants.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks & Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter tasks
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(AppRouter.settings);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 64),
              SizedBox(height: 16),
              Text(
                'No tasks yet',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Tasks will appear here when documents have upcoming expiry dates',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create manual task
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
