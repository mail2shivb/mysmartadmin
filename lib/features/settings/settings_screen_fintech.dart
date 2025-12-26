import 'package:flutter/material.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/typography.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/insight_card.dart';
import '../../core/utils/constants.dart';
import '../../app/app.dart';

/// Settings screen - Fintech-grade simplicity
/// 
/// User controls ONLY:
/// - Theme Mode (System/Light/Dark)
/// 
/// Designer controls everything else:
/// - Fixed accent color (indigo)
/// - Canvas colors (premium dark/light)
/// - Typography, spacing, components
/// 
/// Follows fintech app patterns (Monzo, Emma)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceProvider.of(context);
    
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      enableScroll: true,
      padding: AppPadding.screen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appearance Section
          const SectionHeader(title: 'Appearance'),
          
          // Theme Mode (ONLY user control)
          _ThemeModeSection(appearance: appearance),
          const SizedBox(height: AppSpacing.xxl),

          // Privacy Section
          const SectionHeader(title: 'Privacy'),
          InsightCard(
            leadingIcon: Icons.privacy_tip_outlined,
            title: 'Privacy First',
            subtitle: AppConstants.privacyStatement,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Storage Section
          const SectionHeader(title: 'Storage'),
          InsightCard(
            leadingIcon: Icons.storage,
            title: 'Local Storage',
            subtitle: '0 MB used · All data on device',
          ),
          const SizedBox(height: AppSpacing.xl),

          // About Section
          const SectionHeader(title: 'About'),
          InsightCard(
            leadingIcon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// Theme Mode section (System/Light/Dark) - ONLY user control
class _ThemeModeSection extends StatelessWidget {
  final dynamic appearance;

  const _ThemeModeSection({required this.appearance});

  @override
  Widget build(BuildContext context) {
    final currentMode = appearance.themeMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: AppTypography.labelMedium(context).copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        
        // System
        _ThemeModeOption(
          mode: ThemeMode.system,
          label: 'System',
          description: 'Follow device settings',
          icon: Icons.brightness_auto_outlined,
          isSelected: currentMode == ThemeMode.system,
          onTap: () => appearance.setThemeMode(ThemeMode.system),
        ),
        
        // Light
        _ThemeModeOption(
          mode: ThemeMode.light,
          label: 'Light',
          description: 'Always light mode',
          icon: Icons.light_mode_outlined,
          isSelected: currentMode == ThemeMode.light,
          onTap: () => appearance.setThemeMode(ThemeMode.light),
        ),
        
        // Dark
        _ThemeModeOption(
          mode: ThemeMode.dark,
          label: 'Dark',
          description: 'Always dark mode',
          icon: Icons.dark_mode_outlined,
          isSelected: currentMode == ThemeMode.dark,
          onTap: () => appearance.setThemeMode(ThemeMode.dark),
        ),
      ],
    );
  }
}

/// Theme mode option tile
class _ThemeModeOption extends StatelessWidget {
  final ThemeMode mode;
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.mode,
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InsightCard(
      leadingIcon: icon,
      title: label,
      subtitle: description,
      trailingIcon: isSelected ? Icons.check_circle : null,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
    );
  }
}

