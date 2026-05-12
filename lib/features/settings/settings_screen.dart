import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Settings — content only. ShellScaffold provides header + back button.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
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
                onTap: () => context.push(AppRouter.vaultUnlock),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.cloud_upload_outlined,
                title: 'Backup & export',
                subtitle: 'Encrypted local backup',
                onTap: () => context.push(AppRouter.backupCodes),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.key_outlined,
                title: 'Recovery key',
                subtitle: 'Store your emergency recovery key',
                onTap: () => context.push(AppRouter.recoveryKey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
        const SectionTitle('Privacy'),
        LCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: const [
              Icon(Icons.lock_outline,
                  color: AppColors.royalPurple, size: 18),
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
        const SectionTitle('Auth screens (demo)'),
        LCard(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            children: [
              ListRow(
                icon: Icons.login_outlined,
                title: 'Sign in / Onboarding',
                onTap: () => context.push(AppRouter.onboarding),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.verified_user_outlined,
                title: 'MFA setup',
                onTap: () => context.push(AppRouter.mfaSetup),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ListRow(
                icon: Icons.pin_outlined,
                title: 'Vault unlock (PIN)',
                onTap: () => context.push(AppRouter.vaultUnlock),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle('About'),
        LCard(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            children: const [
              ListRow(icon: Icons.menu_book_outlined, title: 'User guide'),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                  icon: Icons.privacy_tip_outlined, title: 'Privacy policy'),
              Divider(height: 1, color: AppColors.divider),
              ListRow(icon: Icons.gavel_outlined, title: 'Terms of service'),
              Divider(height: 1, color: AppColors.divider),
              ListRow(
                  icon: Icons.info_outline, title: 'App version', subtitle: '1.0.0'),
            ],
          ),
        ),
      ],
    );
  }
}
