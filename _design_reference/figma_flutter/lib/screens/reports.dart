import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shell.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeTab: 4,
      header: SlackStyleHeader(title: 'Reports', subtitle: 'Insights across your vault', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Overview'),
          Row(children: [
            Expanded(child: _stat('Records', '112', AppColors.royal)),
            const SizedBox(width: 10),
            Expanded(child: _stat('Reminders', '8', AppColors.warn)),
            const SizedBox(width: 10),
            Expanded(child: _stat('Overdue', '3', AppColors.urgent)),
          ]),
          const SizedBox(height: 14),
          const SectionTitle('Reports'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.bar_chart_rounded, title: 'Monthly bills', subtitle: 'Apr 2026',
                onTap: () => Navigator.pushNamed(context, '/report-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.event_note_outlined, title: 'Renewals due in 90 days',
                onTap: () => Navigator.pushNamed(context, '/report-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.timeline_outlined, title: 'Life timeline',
                onTap: () => Navigator.pushNamed(context, '/life-timeline')),
          ])),
        ])),
      ]),
    );
  }
}

class _stat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.lavBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
    ]),
  );
}

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Monthly bills', subtitle: 'April 2026', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Total', style: TextStyle(color: AppColors.text2, fontSize: 12)),
            SizedBox(height: 4),
            Text('£487.62', style: TextStyle(color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w700)),
          ])),
          const SizedBox(height: 12),
          LCard(child: Column(children: const [
            ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy', subtitle: 'Utilities', trailing: Text('£92.40', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500))),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.shield_outlined, title: 'Aviva car insurance', subtitle: 'Insurance', trailing: Text('£58.10', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500))),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.subscriptions_outlined, title: 'Netflix', subtitle: 'Subscriptions', trailing: Text('£10.99', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500))),
          ])),
        ])),
      ]),
    );
  }
}

class LifeTimelineScreen extends StatelessWidget {
  const LifeTimelineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Life timeline', subtitle: 'Major events in your records', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: LCard(child: Column(children: const [
          ListRow(icon: Icons.flag_outlined, title: 'Aug 2026', subtitle: 'Passport expires'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.flag_outlined, title: 'May 2026', subtitle: 'Home insurance renewal'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.flag_outlined, title: 'Apr 2026', subtitle: 'Tenancy renewed'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.flag_outlined, title: 'Feb 2026', subtitle: 'Joined LedgerAI'),
        ]))),
      ]),
    );
  }
}
