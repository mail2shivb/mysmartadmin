import 'package:flutter/material.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_shadows.dart';

/// Prototype 5-tab bottom nav: Home | Vault | ＋ (centre FAB) | Reminders | Reports
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
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _NavTab(
                icon: Icons.home_rounded, label: 'Dashboard',
                index: 0, currentIndex: currentIndex, onTap: onTabSelected,
              ),
              _NavTab(
                icon: Icons.receipt_long_rounded, label: 'Bills',
                index: 1, currentIndex: currentIndex, onTap: onTabSelected,
              ),
              _AddFab(onPressed: onAddPressed),
              _NavTab(
                icon: Icons.description_rounded, label: 'Documents',
                index: 3, currentIndex: currentIndex, onTap: onTabSelected,
              ),
              _NavTab(
                icon: Icons.notifications_rounded, label: 'Reminders',
                index: 4, currentIndex: currentIndex, onTap: onTabSelected,
              ),
            ],
          ),
        ),
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
    final color = active ? AppColors.primaryPurple : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color, fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.royalPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.elevatedAdd,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
