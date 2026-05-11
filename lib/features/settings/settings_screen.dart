import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Settings screen — account, preferences, and app info.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Settings',
      subtitle: 'Account, preferences and privacy',
      onBack: () => Navigator.of(context).maybePop(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          // ── Account ───────────────────────────────────────────────────────
          const SectionTitle('Account'),
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: [
                ListRow(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Your name, email, and mobile',
                  onTap: () => context.push(AppRouter.profile),
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.lock_outline,
                  title: 'Security',
                  subtitle: 'PIN, biometrics, vault lock',
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Backup & export',
                  subtitle: 'Encrypted local backup',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Preferences ───────────────────────────────────────────────────
          const SectionTitle('Preferences'),
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: const [
                ListRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Reminders, renewals, bills',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English (UK)',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.currency_pound_outlined,
                  title: 'Currency',
                  subtitle: 'GBP (£)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Privacy ───────────────────────────────────────────────────────
          const SectionTitle('Privacy'),
          LCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, color: AppColors.royalPurple, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your data stays on this device. Nothing is sent to a server without your explicit consent.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────────────────────
          const SectionTitle('About'),
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: const [
                ListRow(
                  icon: Icons.menu_book_outlined,
                  title: 'User guide',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy policy',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.gavel_outlined,
                  title: 'Terms of service',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.info_outline,
                  title: 'App version',
                  subtitle: '1.0.0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
