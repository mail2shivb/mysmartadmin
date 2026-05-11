import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shell.dart';

class RemindersTasksScreen extends StatefulWidget {
  const RemindersTasksScreen({super.key});
  @override
  State<RemindersTasksScreen> createState() => _RemindersTasksScreenState();
}

class _RemindersTasksScreenState extends State<RemindersTasksScreen> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeTab: 3,
      header: SlackStyleHeader(
        title: 'Reminders',
        subtitle: '8 upcoming · 3 overdue',
        searchHint: 'Search reminders and tasks…',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FilterChipRow(
            chips: const ['All', 'Bills', 'Renewals', 'Tasks', 'Overdue'],
            active: _filter,
            onChange: (c) => setState(() => _filter = c),
          ),
          const SizedBox(height: 14),
          const SectionTitle('Today'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy bill', subtitle: 'Due today · £92.40',
                badge: const StatusBadge(kind: BadgeKind.urgent, label: 'Today'),
                onTap: () => Navigator.pushNamed(context, '/reminder-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.checklist_rounded, title: 'Sign tenancy renewal', subtitle: 'Personal task',
                badge: const StatusBadge(kind: BadgeKind.due, label: 'Today'),
                onTap: () => Navigator.pushNamed(context, '/task-detail')),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('This week'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.shield_outlined, title: 'AXA Home Insurance renewal', subtitle: 'Due 22 May',
                badge: const StatusBadge(kind: BadgeKind.expiring, label: 'Soon'),
                onTap: () => Navigator.pushNamed(context, '/reminder-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.local_hospital_outlined, title: 'Book GP appointment', subtitle: 'Health task',
                onTap: () => Navigator.pushNamed(context, '/task-detail')),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('Later'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.badge_outlined, title: 'Renew passport', subtitle: 'Due 14 Aug',
                badge: const StatusBadge(kind: BadgeKind.info, label: 'Later'),
                onTap: () => Navigator.pushNamed(context, '/reminder-detail')),
          ])),
        ])),
      ]),
    );
  }
}

class AddReminderScreen extends StatelessWidget {
  const AddReminderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Add reminder', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        LCard(child: Column(children: const [
          LField(label: 'Title', hint: 'e.g. Renew car insurance'),
          LField(label: 'Linked record', hint: 'Optional'),
          LField(label: 'Due date'),
          LField(label: 'Repeat', hint: 'None / Weekly / Monthly / Yearly'),
          LField(label: 'Notify me', hint: '7 days before'),
          LField(label: 'Notes'),
        ])),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Save reminder', onPressed: () => Navigator.pop(context)),
      ])),
    );
  }
}

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Octopus Energy bill', subtitle: 'Due today', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const StatusBadge(kind: BadgeKind.urgent, label: 'Due today'),
          const SizedBox(height: 14),
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _kv('Provider', 'Octopus Energy'),
            _kv('Amount', '£92.40'),
            _kv('Due', '7 May 2026'),
            _kv('Repeat', 'Monthly'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Mark as done', onPressed: () => Navigator.pop(context)),
          const SizedBox(height: 8),
          GhostButton(label: 'Snooze', onPressed: () {}),
        ])),
      ]),
    );
  }
}

class _kv extends StatelessWidget {
  final String k; final String v;
  const _kv(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 120, child: Text(k, style: const TextStyle(color: AppColors.text2, fontSize: 12))),
      Expanded(child: Text(v, style: const TextStyle(color: AppColors.text, fontSize: 14))),
    ]),
  );
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Tasks', subtitle: 'Personal · Household · Shared', searchHint: 'Search tasks…', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Today'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.checklist_rounded, title: 'Sign tenancy renewal', subtitle: 'Personal',
                badge: const StatusBadge(kind: BadgeKind.due, label: 'Today'),
                onTap: () => Navigator.pushNamed(context, '/task-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.local_hospital_outlined, title: 'Book GP appointment', subtitle: 'Personal',
                onTap: () => Navigator.pushNamed(context, '/task-detail')),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('This week'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.shopping_basket_outlined, title: 'Weekly grocery order', subtitle: 'Household',
                onTap: () => Navigator.pushNamed(context, '/task-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.group_outlined, title: 'Plan family weekend', subtitle: 'Shared with Sam',
                badge: const StatusBadge(kind: BadgeKind.info, label: 'Shared'),
                onTap: () => Navigator.pushNamed(context, '/task-detail')),
          ])),
        ])),
      ]),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Add task', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        LCard(child: Column(children: const [
          LField(label: 'Title'),
          LField(label: 'Type', hint: 'Personal / Household / Work / Shared'),
          LField(label: 'Due date'),
          LField(label: 'Assign to', hint: 'Optional'),
          LField(label: 'Notes'),
        ])),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Save task', onPressed: () => Navigator.pop(context)),
      ])),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Sign tenancy renewal', subtitle: 'Personal task', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(children: [
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _kv('Type', 'Personal'),
            _kv('Due', '7 May 2026'),
            _kv('Status', 'In progress'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Mark as done', onPressed: () => Navigator.pop(context)),
        ])),
      ]),
    );
  }
}
