import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Version History — content only. ShellScaffold provides header + back button.
class VersionHistoryScreen extends StatelessWidget {
  const VersionHistoryScreen({super.key});

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
                icon: Icons.history,
                title: 'Current — 18 Apr 2026',
                subtitle: 'Renewal updated',
                badge: StatusBadge(kind: BadgeKind.success, label: 'Current'),
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.history,
                title: 'Version 2 — 22 May 2025',
                subtitle: 'Premium adjusted',
              ),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.history,
                title: 'Version 1 — 22 May 2024',
                subtitle: 'Original policy',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
