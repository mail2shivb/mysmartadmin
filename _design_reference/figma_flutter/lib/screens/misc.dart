import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shell.dart';

class EmergencyPackScreen extends StatelessWidget {
  const EmergencyPackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Emergency pack', subtitle: 'Critical info at your fingertips', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LCard(child: Column(children: const [
            ListRow(icon: Icons.medical_services_outlined, title: 'Medical info', subtitle: 'Blood type, allergies'),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.contact_phone_outlined, title: 'Emergency contacts', subtitle: '3 contacts'),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.badge_outlined, title: 'IDs', subtitle: 'Passport, NHS number'),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.shield_outlined, title: 'Insurance', subtitle: 'AXA, Aviva'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Share pack', onPressed: () {}),
        ])),
      ]),
    );
  }
}

class BackupExportScreen extends StatelessWidget {
  const BackupExportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Backup & export', subtitle: 'Encrypted, end-to-end', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LCard(child: Column(children: const [
            ListRow(icon: Icons.cloud_upload_outlined, title: 'Last backup', subtitle: '6 May 2026 · 02:14',
                badge: StatusBadge(kind: BadgeKind.success, label: 'Encrypted')),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.download_outlined, title: 'Export to PDF', subtitle: 'All records'),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.archive_outlined, title: 'Export to ZIP', subtitle: 'Original files'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Back up now', onPressed: () {}),
        ])),
      ]),
    );
  }
}

class ProviderContactsScreen extends StatelessWidget {
  const ProviderContactsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Provider contacts', searchHint: 'Search providers…', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: LCard(child: Column(children: const [
          ListRow(icon: Icons.shield_outlined, title: 'AXA UK', subtitle: '0330 024 1158'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.shield_outlined, title: 'Aviva', subtitle: '0345 030 6925'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.account_balance_outlined, title: 'Halifax', subtitle: '0345 720 3040'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy', subtitle: '0808 164 1088'),
        ]))),
      ]),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Profile', subtitle: 'Alex Morgan', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            LField(label: 'Full name', initialValue: 'Alex Morgan'),
            LField(label: 'Email', initialValue: 'alex@example.co.uk'),
            LField(label: 'Mobile', initialValue: '+44 7700 900123'),
          ])),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Save profile', onPressed: () => Navigator.pop(context)),
        ])),
      ]),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Settings', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Account'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.person_outline, title: 'Profile', onTap: () => Navigator.pushNamed(context, '/profile')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.lock_outline, title: 'Security', onTap: () => Navigator.pushNamed(context, '/security-settings')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.cloud_upload_outlined, title: 'Backup & export', onTap: () => Navigator.pushNamed(context, '/backup-export')),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('Preferences'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.notifications_none_rounded, title: 'Notifications'),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.language_outlined, title: 'Language', subtitle: 'English (UK)'),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.help_outline, title: 'Help & about', onTap: () => Navigator.pushNamed(context, '/help-about')),
          ])),
        ])),
      ]),
    );
  }
}

class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Help & about', subtitle: 'LedgerAI v1.0.0', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: LCard(child: Column(children: const [
          ListRow(icon: Icons.menu_book_outlined, title: 'User guide'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.privacy_tip_outlined, title: 'Privacy policy'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.gavel_outlined, title: 'Terms of service'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.support_agent_outlined, title: 'Contact support'),
        ]))),
      ]),
    );
  }
}

class _PermissionScreen extends StatelessWidget {
  final IconData icon; final String title; final String body;
  const _PermissionScreen({required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(children: [
        const SizedBox(height: 30),
        Container(
          width: 84, height: 84,
          decoration: BoxDecoration(
            gradient: AppColors.purpleButton,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(icon, color: Colors.white, size: 42),
        ),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(body, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text2, fontSize: 14))),
        const SizedBox(height: 24),
        AuthCard(child: Column(children: [
          PrimaryButton(label: 'Allow', onPressed: () => Navigator.pop(context)),
          const SizedBox(height: 8),
          GhostButton(label: 'Not now', onPressed: () => Navigator.pop(context)),
        ])),
      ]),
    );
  }
}

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PermissionScreen(
    icon: Icons.notifications_active_outlined,
    title: 'Stay on top of renewals',
    body: 'Allow notifications so we can remind you about bills, renewals, and tasks before they expire.',
  );
}

class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PermissionScreen(
    icon: Icons.camera_alt_outlined,
    title: 'Capture documents quickly',
    body: 'Allow camera access to photograph documents, bills, and policies.',
  );
}

class FilePermissionScreen extends StatelessWidget {
  const FilePermissionScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PermissionScreen(
    icon: Icons.folder_open_outlined,
    title: 'Import from files',
    body: 'Allow file access to import PDFs, images, and saved documents into your vault.',
  );
}

class BiometricPermissionScreen extends StatelessWidget {
  const BiometricPermissionScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PermissionScreen(
    icon: Icons.fingerprint,
    title: 'Unlock with biometrics',
    body: 'Use Face ID or fingerprint to unlock your vault securely.',
  );
}

class LoadingStateScreen extends StatelessWidget {
  const LoadingStateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Loading', onBack: () => Navigator.pop(context)),
      body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class ErrorStateScreen extends StatelessWidget {
  const ErrorStateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Something went wrong', onBack: () => Navigator.pop(context)),
      body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 56, color: AppColors.urgent),
        const SizedBox(height: 12),
        const Text("We couldn't load this page", style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Check your connection and try again.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Retry', onPressed: () => Navigator.pop(context)),
      ]))),
    );
  }
}

class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Nothing here yet', onBack: () => Navigator.pop(context)),
      body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inbox_outlined, size: 56, color: AppColors.textMuted),
        const SizedBox(height: 12),
        const Text('Your vault is empty', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Add your first record to get started.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Add a record', onPressed: () => Navigator.pushNamed(context, '/add-record')),
      ]))),
    );
  }
}
