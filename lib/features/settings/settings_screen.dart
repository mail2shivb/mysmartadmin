import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

/// Settings screen
/// 
/// Features:
/// - Privacy settings
/// - Storage management
/// - About app
/// - No cloud sync options (offline-first by design)
/// 
/// Opened via AppBar settings icon from Home, Documents, and Tasks
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Privacy'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Statement'),
            subtitle: const Text(AppConstants.privacyStatement),
          ),
          const Divider(),
          const _SectionHeader(title: 'Storage'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Local Storage'),
            subtitle: const Text('All data stored on device'),
            trailing: const Text('0 MB'),
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('App Name'),
            subtitle: const Text(AppConstants.appName),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        24,
        AppConstants.defaultPadding,
        8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
