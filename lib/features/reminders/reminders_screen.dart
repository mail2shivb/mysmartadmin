import 'package:flutter/material.dart';

/// Reminders management screen (temporarily disabled)
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reminders UI disabled temporarily'),
      ),
    );
  }
}

/*
// ORIGINAL CODE COMMENTED OUT FOR STABILIZATION

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/usecases/reminders/get_upcoming_reminders_usecase.dart';
import '../../domain/usecases/reminders/snooze_reminder_usecase.dart';
import '../../domain/usecases/reminders/complete_reminder_usecase.dart';
import '../../data/local/tables/reminders.dart';

/// Reminders management screen
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _database = DatabaseProvider.instance;
  late final _getUpcomingRemindersUseCase = GetUpcomingRemindersUseCase(_database);
  late final _snoozeReminderUseCase = SnoozeReminderUseCase(_database);
  late final _completeReminderUseCase = CompleteReminderUseCase(_database);

  List<ReminderEntity> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _loading = true);
    try {
      final reminders = await _getUpcomingRemindersUseCase(lookaheadDays: 30);
      setState(() {
        _reminders = reminders;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _snoozeReminder(ReminderEntity reminder) async {
    final snoozeDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (snoozeDate == null) return;

    try {
      final success = await _snoozeReminderUseCase(
        reminderId: reminder.id,
        snoozeUntil: snoozeDate,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder snoozed')),
          );
          _loadReminders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to snooze reminder')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completeReminder(ReminderEntity reminder) async {
    try {
      final success = await _completeReminderUseCase(reminder.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder completed')),
          );
          _loadReminders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to complete reminder')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? const Center(child: Text('No upcoming reminders'))
              : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    final isOverdue = _isOverdue(reminder.reminderDate);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isOverdue ? Colors.red.shade50 : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: isOverdue ? Colors.red : null,
                        ),
                        title: Text(reminder.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reminder.description != null)
                              Text(reminder.description!),
                            const SizedBox(height: 4),
                            Text(
                              '${reminder.reminderType} • ${_formatDate(reminder.reminderDate)}',
                              style: TextStyle(
                                color: isOverdue ? Colors.red : Colors.grey,
                                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'snooze',
                              child: Row(
                                children: [
                                  Icon(Icons.snooze),
                                  SizedBox(width: 8),
                                  Text('Snooze'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'complete',
                              child: Row(
                                children: [
                                  Icon(Icons.check),
                                  SizedBox(width: 8),
                                  Text('Complete'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'snooze') {
                              _snoozeReminder(reminder);
                            } else if (value == 'complete') {
                              _completeReminder(reminder);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
*/
