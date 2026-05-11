import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import '../core/proto_theme/app_colors.dart';

/// Shell scaffold — gradient header + rounded white content area + bottom nav.
/// Tab screens return ONLY their scrollable content (ListView/CustomScrollView).
/// This widget handles the full visual chrome for all 5 tabs.
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
    final info = _headerInfoFor(location);
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

  _HeaderInfo _headerInfoFor(String loc) {
    if (loc.startsWith(AppRouter.vault)) {
      return _HeaderInfo(
        title: 'My Vault',
        subtitle: 'All your documents in one place',
        searchHint: 'Search vault…',
        trailing: (ctx) => HeaderIcon(
          icon: Icons.tune_rounded,
          onTap: () => ctx.go(AppRouter.search),
        ),
      );
    }
    if (loc.startsWith(AppRouter.reminders)) {
      return const _HeaderInfo(
        title: 'Reminders',
        subtitle: 'Renewals, deadlines and bills',
        searchHint: null,
      );
    }
    if (loc.startsWith(AppRouter.reports)) {
      return const _HeaderInfo(
        title: 'Reports & Insights',
        subtitle: 'Understand your life admin',
        searchHint: null,
      );
    }
    // Default: home
    return _HeaderInfo(
      title: 'LedgerAI',
      subtitle: 'Your life admin, privately on this device',
      searchHint: 'Search records, reminders, tasks…',
      trailing: (ctx) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () => ctx.go(AppRouter.reminders),
          ),
          const SizedBox(width: 8),
          HeaderIcon(
            icon: Icons.settings_outlined,
            onTap: () => ctx.push(AppRouter.settings),
          ),
        ],
      ),
    );
  }

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

  const _HeaderInfo({
    required this.title,
    this.subtitle,
    this.searchHint,
    Widget Function(BuildContext)? trailing,
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

  const _GradientHeader({
    required this.title,
    this.subtitle,
    this.searchHint,
    this.trailing,
    this.onSearchTap,
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

// ── HeaderIcon (re-exported for other widgets that import shell_scaffold) ─────

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
                              color:
                                  AppColors.royalPurple.withValues(alpha: 0.35),
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
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _AddActionSheet ───────────────────────────────────────────────────────────

class _AddActionSheet extends StatelessWidget {
  final BuildContext parentContext;
  const _AddActionSheet({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.edit_note_outlined,
        'Add manually',
        'Enter details without uploading anything',
        AppRouter.addRecord,
      ),
      (
        Icons.camera_alt_outlined,
        'Take a photo',
        'Photograph a document, then review extracted details',
        AppRouter.addDocument,
      ),
      (
        Icons.image_outlined,
        'Choose from library',
        'Select an image from your photos',
        AppRouter.addDocument,
      ),
      (
        Icons.upload_file_outlined,
        'Import from files',
        'Add a PDF, image, or saved document',
        AppRouter.addDocument,
      ),
      (
        Icons.notifications_active_outlined,
        'Add reminder',
        'Create a renewal, expiry, or payment reminder',
        AppRouter.addReminder,
      ),
    ];

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
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ...items.map(
              (it) => InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  parentContext.go(it.$4);
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.paleLavender,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(it.$1,
                            color: AppColors.royalPurple, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.$2,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              it.$3,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
