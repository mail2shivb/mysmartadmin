import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Reminder Detail — shows due date, amount, repeat schedule, and actions.
class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Octopus Energy bill',
      subtitle: 'Due today',
      onBack: () => Navigator.of(context).maybePop(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          const StatusBadge(kind: BadgeKind.urgent, label: 'Due today'),
          const SizedBox(height: 16),
          LCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _KV('Provider', 'Octopus Energy'),
                _KV('Amount', '£92.40'),
                _KV('Due', '7 May 2026'),
                _KV('Repeat', 'Monthly'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LPrimaryButton(
            label: 'Mark as done',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 8),
          LGhostButton(
            label: 'Snooze',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(k,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
          ],
        ),
      );
}
