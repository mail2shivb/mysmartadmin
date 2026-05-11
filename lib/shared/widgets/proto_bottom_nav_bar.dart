import 'package:flutter/material.dart';
import '../../core/proto_theme/app_colors.dart';

/// 5-tab bottom nav: Home | Vault | ＋ (FAB) | Reminders | Reports
class ProtoBottomNavBar extends StatelessWidget {
  const ProtoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F5B1B73),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavTab(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            currentIndex: currentIndex,
            onTap: onTabSelected,
          ),
          _NavTab(
            icon: Icons.lock_outline_rounded,
            label: 'Vault',
            index: 1,
            currentIndex: currentIndex,
            onTap: onTabSelected,
          ),
          _AddFab(onPressed: onAddPressed),
          _NavTab(
            icon: Icons.notifications_none_rounded,
            label: 'Reminders',
            index: 3,
            currentIndex: currentIndex,
            onTap: onTabSelected,
          ),
          _NavTab(
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
            index: 4,
            currentIndex: currentIndex,
            onTap: onTabSelected,
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = currentIndex == index;
    final color =
        active ? AppColors.primaryPurple : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: active
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.purpleButton,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple
                      .withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child:
                const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
