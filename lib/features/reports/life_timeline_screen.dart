import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Life Timeline — content only. ShellScaffold provides header + back button.
class LifeTimelineScreen extends StatelessWidget {
  const LifeTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        LCard(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            children: const [
              ListRow(
                icon: Icons.flag_outlined,
                title: 'Aug 2026',
                subtitle: 'Passport expires',
                badge: StatusBadge(kind: BadgeKind.review, label: 'Upcoming'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.flag_outlined,
                title: 'May 2026',
                subtitle: 'Home insurance renewal',
                badge: StatusBadge(kind: BadgeKind.expiring, label: 'Soon'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.flag_outlined,
                title: 'Apr 2026',
                subtitle: 'Tenancy renewed',
                badge: StatusBadge(kind: BadgeKind.success, label: 'Done'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.flag_outlined,
                title: 'Feb 2026',
                subtitle: 'Joined LedgerAI',
                badge: StatusBadge(kind: BadgeKind.active, label: 'Active'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.flag_outlined,
                title: 'Sep 2025',
                subtitle: 'Car insurance renewed',
                badge: StatusBadge(kind: BadgeKind.active, label: 'Active'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
