import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Emergency Pack — critical personal information at a glance.
class EmergencyPackScreen extends StatelessWidget {
  const EmergencyPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Emergency pack',
      subtitle: 'Critical info at your fingertips',
      onBack: () => Navigator.of(context).maybePop(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: const [
                ListRow(
                  icon: Icons.medical_services_outlined,
                  title: 'Medical info',
                  subtitle: 'Blood type, allergies',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.contact_phone_outlined,
                  title: 'Emergency contacts',
                  subtitle: '3 contacts',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.badge_outlined,
                  title: 'IDs',
                  subtitle: 'Passport, NHS number',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.shield_outlined,
                  title: 'Insurance',
                  subtitle: 'AXA, Aviva',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LPrimaryButton(
            label: 'Share pack',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
