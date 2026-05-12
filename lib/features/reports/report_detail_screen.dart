import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Report Detail — content only. ShellScaffold provides header + back button.
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                trailing: _Amt('£92.40'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.shield_outlined,
                title: 'Aviva car insurance',
                subtitle: 'Insurance',
                trailing: _Amt('£58.10'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.subscriptions_outlined,
                title: 'Netflix',
                subtitle: 'Subscriptions',
                trailing: _Amt('£10.99'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.receipt_long_outlined,
                title: 'Internet (Sky)',
                subtitle: 'Utilities',
                trailing: _Amt('£45.00'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.account_balance_outlined,
                title: 'Halifax mortgage',
                subtitle: 'Banking',
                trailing: _Amt('£281.13'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Amt extends StatelessWidget {
  final String text;
  const _Amt(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500));
}
