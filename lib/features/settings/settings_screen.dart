import 'package:flutter/material.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/colors.dart';
import '../../core/ui/typography.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/insight_card.dart';
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      enableScroll: true,
      padding: AppPadding.screen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy section
          const SectionHeader(title: 'Privacy'),
          InsightCard(
            leadingIcon: Icons.privacy_tip_outlined,
            leadingIconColor: AppColors.success,
            leadingIconBackground: AppColors.successLight,
            title: 'Privacy First',
            subtitle: AppConstants.privacyStatement,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Storage section
          const SectionHeader(title: 'Storage'),
          InsightCard(
            leadingIcon: Icons.storage,
            leadingIconColor: AppColors.info,
            leadingIconBackground: AppColors.infoLight,
            title: 'Local Storage',
            subtitle: '0 MB used · All data on device',
          ),
          const SizedBox(height: AppSpacing.xl),

          // About section
          const SectionHeader(title: 'About'),
          InsightCard(
            leadingIcon: Icons.info_outline,
            title: 'Version',
            subtitle: AppConstants.appVersion,
          ),
          InsightCard(
            leadingIcon: Icons.description_outlined,
            title: 'App Name',
            subtitle: AppConstants.appName,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Footer
          Center(
            child: Text(
              'Made with privacy in mind',
              style: AppTypography.subtle(context),
            ),
          ),
        ],
      ),
    );
  }
}
