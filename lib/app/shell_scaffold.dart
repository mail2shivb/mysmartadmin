import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import '../core/proto_theme/app_colors.dart';

/// Shell scaffold — gradient header + rounded white content area + bottom nav.
/// Tab screens return ONLY their scrollable content (ListView/Column).
/// Sub-screens also return content only — the shell supplies the header + back button.
class ShellScaffold extends StatelessWidget {
  final String location;
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final info = _headerInfoFor(location, context);
    final currentIndex = AppRouter.getIndexForLocation(location);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF7B2CBF),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GradientHeader(
              title: info.title,
              subtitle: info.subtitle,
              searchHint: info.searchHint,
              trailing: info.trailing(context),
              onSearchTap: () => context.push(AppRouter.search),
              onBack: info.onBack,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ],
        ),
        bottomNavigationBar: _ProtoBottomNavBar(
          currentIndex: currentIndex,
          onTap: (i) {
            if (i == 2) {
              _showAddSheet(context);
            } else {
              context.go(AppRouter.getLocationForIndex(i));
            }
          },
        ),
      ),
    );
  }

  // ── Per-route header configuration ────────────────────────────────────────

  // Most-specific routes first to avoid prefix collisions.
  _HeaderInfo _headerInfoFor(String loc, BuildContext ctx) {
    // Vault category (before vault tab check)
    if (loc.startsWith('/vault/category/')) {
      final domainId = loc.substring('/vault/category/'.length);
      final label = _kCatLabels[domainId] ?? _titleCase(domainId);
      return _HeaderInfo(
        title: label,
        subtitle: '$label records and reminders',
        onBack: () => ctx.pop(),
      );
    }

    // Reports sub-screens (before reports tab check)
    if (loc == AppRouter.reportDetail) {
      return _HeaderInfo(title: 'Monthly bills', subtitle: 'April 2026',
          onBack: () => ctx.pop());
    }
    if (loc == AppRouter.lifeTimeline) {
      return _HeaderInfo(title: 'Life timeline',
          subtitle: 'Major events in your records', onBack: () => ctx.pop());
    }

    // Reminders sub-screens (before reminders tab check)
    if (loc == AppRouter.reminderDetail) {
      return _HeaderInfo(title: 'Reminder', subtitle: 'Due date and actions',
          onBack: () => ctx.pop());
    }

    // Record sub-screens
    if (loc == AppRouter.recordDetail) {
      return _HeaderInfo(
        title: 'Record',
        subtitle: 'Details and documents',
        onBack: () => ctx.pop(),
        trailing: (c) => const _MoreButton(),
      );
    }
    if (loc == AppRouter.versionHistory) {
      return _HeaderInfo(title: 'Version history', onBack: () => ctx.pop());
    }

    // Settings & Profile
    if (loc == AppRouter.settings) {
      return _HeaderInfo(title: 'Settings',
          subtitle: 'Account, preferences and privacy',
          onBack: () => ctx.pop());
    }
    if (loc == AppRouter.profile) {
      return _HeaderInfo(title: 'Profile', subtitle: 'Your details',
          onBack: () => ctx.pop());
    }

    // Emergency pack
    if (loc == AppRouter.emergencyPack) {
      return _HeaderInfo(title: 'Emergency pack',
          subtitle: 'Critical info at your fingertips', onBack: () => ctx.pop());
    }

    // Search
    if (loc == AppRouter.search) {
      return _HeaderInfo(title: 'Search', subtitle: 'Records, reminders, tasks…',
          onBack: () => ctx.pop());
    }

    // ── Tab screens ──────────────────────────────────────────────────────
    if (loc.startsWith(AppRouter.vault)) {
      return _HeaderInfo(
        title: 'My Vault',
        subtitle: 'All your documents in one place',
        searchHint: 'Search vault…',
        trailing: (c) => HeaderIcon(
          icon: Icons.tune_rounded,
          onTap: () => c.push(AppRouter.search),
        ),
      );
    }
    if (loc.startsWith(AppRouter.reminders)) {
      return const _HeaderInfo(
        title: 'Reminders',
        subtitle: 'Renewals, deadlines and bills',
      );
    }
    if (loc.startsWith(AppRouter.reports)) {
      return const _HeaderInfo(
        title: 'Reports & Insights',
        subtitle: 'Understand your life admin',
      );
    }

    // Default: home
    return _HeaderInfo(
      title: 'LedgerAI',
      subtitle: 'Your life admin, privately on this device',
      searchHint: 'Search records, reminders, tasks…',
      trailing: (c) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () => c.go(AppRouter.reminders),
          ),
          const SizedBox(width: 8),
          HeaderIcon(
            icon: Icons.settings_outlined,
            onTap: () => c.push(AppRouter.settings),
          ),
        ],
      ),
    );
  }

  static String _titleCase(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  static const _kCatLabels = <String, String>{
    'identity_legal': 'Identity & Legal',
    'home_property': 'Home & Property',
    'vehicles_transport': 'Vehicles & Transport',
    'banking_credit_borrowing': 'Banking & Credit',
    'banking_credit': 'Banking & Credit',
    'insurance_protection': 'Insurance',
    'insurance': 'Insurance',
    'bills_utilities_subscriptions': 'Bills & Utilities',
    'bills_utilities': 'Bills & Utilities',
    'work_income_tax': 'Work & Income',
    'person_family': 'People & Family',
  };

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddActionSheet(parentContext: context),
    );
  }
}

// ── _HeaderInfo ───────────────────────────────────────────────────────────────

class _HeaderInfo {
  final String title;
  final String? subtitle;
  final String? searchHint;
  final Widget Function(BuildContext)? _trailing;
  final VoidCallback? onBack;

  const _HeaderInfo({
    required this.title,
    this.subtitle,
    this.searchHint,
    Widget Function(BuildContext)? trailing,
    this.onBack,
  }) : _trailing = trailing;

  Widget? trailing(BuildContext ctx) => _trailing?.call(ctx);
}

// ── _GradientHeader ───────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? searchHint;
  final Widget? trailing;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBack;

  const _GradientHeader({
    required this.title,
    this.subtitle,
    this.searchHint,
    this.trailing,
    this.onSearchTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                GestureDetector(
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 13,
              ),
            ),
          ],
          if (searchHint != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      searchHint!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── HeaderIcon ────────────────────────────────────────────────────────────────

class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const HeaderIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── _MoreButton ───────────────────────────────────────────────────────────────

class _MoreButton extends StatelessWidget {
  const _MoreButton();

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {},
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: const Icon(Icons.more_horiz_rounded,
              color: Colors.white, size: 18),
        ),
      );
}

// ── _ProtoBottomNavBar ────────────────────────────────────────────────────────

class _ProtoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ProtoBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  current: currentIndex,
                  onTap: onTap),
              _NavItem(
                  index: 1,
                  icon: Icons.lock_outline_rounded,
                  activeIcon: Icons.lock_rounded,
                  label: 'Vault',
                  current: currentIndex,
                  onTap: onTap),
              // Centre add button
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleButton,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.royalPurple
                                  .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                  index: 3,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications_rounded,
                  label: 'Reminders',
                  current: currentIndex,
                  onTap: onTap),
              _NavItem(
                  index: 4,
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  current: currentIndex,
                  onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? AppColors.royalPurple : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.royalPurple : AppColors.textMuted,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _AddActionSheet ───────────────────────────────────────────────────────────

class _AddActionSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _AddActionSheet({required this.parentContext});

  @override
  State<_AddActionSheet> createState() => _AddActionSheetState();
}

class _AddActionSheetState extends State<_AddActionSheet> {
  bool _moreExpanded = false;

  static const _mainItems = <(IconData, String, String, String)>[
    (
      Icons.document_scanner_outlined,
      'Scan Document',
      'Capture and extract details from a document',
      '${AppRouter.addRecord}?mode=scan',
    ),
    (
      Icons.camera_alt_outlined,
      'Take a Photo',
      'Photograph a document, bill, policy, warranty, or paperwork',
      '${AppRouter.addRecord}?mode=camera',
    ),
    (
      Icons.image_outlined,
      'Choose from Library',
      'Select an image from your photos',
      '${AppRouter.addRecord}?mode=library',
    ),
    (
      Icons.upload_file_outlined,
      'Import from Files',
      'Add a PDF, image, or saved document',
      '${AppRouter.addRecord}?mode=import',
    ),
    (
      Icons.edit_note_outlined,
      'Add Manually',
      'Enter details without uploading anything',
      '${AppRouter.addRecord}?mode=manual',
    ),
    (
      Icons.notifications_active_outlined,
      'Add Reminder',
      'Create a renewal, expiry, or payment reminder',
      AppRouter.addReminder,
    ),
  ];

  static const _moreItems = <(IconData, String, String)>[
    (Icons.task_alt_outlined, 'Add Task', AppRouter.addTask),
    (Icons.share_outlined, 'Add Shared Item', AppRouter.addSharedItem),
    (Icons.person_add_outlined, 'Add Person / Family Member', AppRouter.addPerson),
    (Icons.work_outline, 'Add Employment Record', AppRouter.addEmployment),
    (Icons.home_work_outlined, 'Add Address Record', AppRouter.addAddress),
    (Icons.smart_toy_outlined, 'Ask LedgerAI', AppRouter.assistantChat),
  ];

  void _navigate(String route) {
    Navigator.of(context).pop();
    widget.parentContext.push(route);
  }

  Widget _buildItem(IconData icon, String title, String subtitle, String route) {
    return InkWell(
      onTap: () => _navigate(route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.paleLavender,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.royalPurple, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreSubItem(IconData icon, String title, String route) {
    return InkWell(
      onTap: () => _navigate(route),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.softLavender,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.mediumPurple, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, size: 15, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const Text(
              'What would you like to add?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scan, upload, or create a record manually.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Main items
            for (final it in _mainItems)
              _buildItem(it.$1, it.$2, it.$3, it.$4),

            const SizedBox(height: 4),

            // More Options toggle row
            InkWell(
              onTap: () => setState(() => _moreExpanded = !_moreExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.paleLavender,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.more_horiz_rounded,
                          color: AppColors.royalPurple, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('More Options',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          Text('Task, shared item, person, employment, address, or ask LedgerAI',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _moreExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            // More Options expanded sub-items
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _moreExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Column(
                        children: [
                          for (final it in _moreItems)
                            _buildMoreSubItem(it.$1, it.$2, it.$3),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.paleLavender,
                  foregroundColor: AppColors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
