import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Report Detail — breakdown of a specific report (e.g. monthly bills).
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Monthly bills',
      subtitle: 'April 2026',
      onBack: () => Navigator.of(context).maybePop(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          LCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Total',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                SizedBox(height: 4),
                Text('£487.62',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: const [
                ListRow(
                  icon: Icons.bolt_outlined,
                  title: 'Octopus Energy',
                  subtitle: 'Utilities',
                  trailing: _Amount('£92.40'),
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.shield_outlined,
                  title: 'Aviva car insurance',
                  subtitle: 'Insurance',
                  trailing: _Amount('£58.10'),
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.subscriptions_outlined,
                  title: 'Netflix',
                  subtitle: 'Subscriptions',
                  trailing: _Amount('£10.99'),
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Internet (Sky)',
                  subtitle: 'Utilities',
                  trailing: _Amount('£45.00'),
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.account_balance_outlined,
                  title: 'Halifax mortgage',
                  subtitle: 'Banking',
                  trailing: _Amount('£281.13'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  final String text;
  const _Amount(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      );
}
