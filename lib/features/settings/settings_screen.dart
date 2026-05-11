import 'package:flutter/material.dart';
import '../../core/ui/colour_variant.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../core/utils/constants.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';
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

    return PageScaffold(
      title: 'Settings',
      subtitle: 'Preferences, security, appearance',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(ProtoSpacing.lg),
        children: [
          // ── Appearance ─────────────────────────────────────────────────
          _SectionLabel('Look and Feel'),
          _ThemeModeSection(appearance: appearance),
          const SizedBox(height: ProtoSpacing.lg),
          _ColourVariantSection(appearance: appearance),

          const SizedBox(height: ProtoSpacing.xl),

          // ── Privacy ────────────────────────────────────────────────────
          _SectionLabel('Privacy on This Device'),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy First',
            subtitle: AppConstants.privacyStatement,
          ),

          const SizedBox(height: ProtoSpacing.xl),

          // ── Storage ────────────────────────────────────────────────────
          _SectionLabel('Local Storage'),
          _SettingsTile(
            icon: Icons.storage_rounded,
            title: 'Local Storage',
            subtitle: '0 MB used · All data on device',
          ),

          const SizedBox(height: ProtoSpacing.xl),

          // ── About ──────────────────────────────────────────────────────
          _SectionLabel('App Information'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
          ),

          const SizedBox(height: ProtoSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: ProtoSpacing.sm),
    child: Text(text,
        style: AppTextStyles.title.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        )),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool selected;
  const _SettingsTile({
    required this.icon, required this.title, required this.subtitle,
    this.onTap, this.selected = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ProtoSpacing.xs),
      child: ProtoAppCard(
        padding: const EdgeInsets.all(ProtoSpacing.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ProtoRadius.lg),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.paleLavender,
                  borderRadius: BorderRadius.circular(ProtoRadius.md),
                ),
                child: Icon(icon,
                    color: selected ? Colors.white : AppColors.deepPurple,
                    size: 20),
              ),
              const SizedBox(width: ProtoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.title.copyWith(fontSize: 15)),
                    Text(subtitle, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primaryPurple),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeSection extends StatelessWidget {
  final dynamic appearance;
  const _ThemeModeSection({required this.appearance});

  @override
  Widget build(BuildContext context) {
    final currentMode = appearance.themeMode as ThemeMode;
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.brightness_auto_outlined,
          title: 'System',
          subtitle: 'Use the same appearance as your device',
          selected: currentMode == ThemeMode.system,
          onTap: () => appearance.setThemeMode(ThemeMode.system),
        ),
        _SettingsTile(
          icon: Icons.light_mode_outlined,
          title: 'Light',
          subtitle: 'Use the light appearance at all times',
          selected: currentMode == ThemeMode.light,
          onTap: () => appearance.setThemeMode(ThemeMode.light),
        ),
        _SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark',
          subtitle: 'Use the dark appearance at all times',
          selected: currentMode == ThemeMode.dark,
          onTap: () => appearance.setThemeMode(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ColourVariantSection extends StatelessWidget {
  final dynamic appearance;
  const _ColourVariantSection({required this.appearance});

  @override
  Widget build(BuildContext context) {
    final current = appearance.colourVariant as AppColourVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Colour Palette'),
        for (final variant in AppColourVariant.values)
          _SettingsTile(
            icon: variant.icon,
            title: variant.displayName,
            subtitle: variant.description,
            selected: current == variant,
            onTap: () => appearance.setColourVariant(variant),
          ),
      ],
    );
  }
}
