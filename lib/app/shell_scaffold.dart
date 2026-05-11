import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import '../core/proto_theme/app_colors.dart';

/// Shell scaffold — wraps each tab with the original mysmartadmin bottom nav.
/// Navigation: Dashboard | Bills | Documents | Reminders | Tasks
class ShellScaffold extends StatelessWidget {
  final String location;
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Bills',
    ),
    NavigationDestination(
      icon: Icon(Icons.description_outlined),
      selectedIcon: Icon(Icons.description_rounded),
      label: 'Documents',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications_rounded),
      label: 'Reminders',
    ),
    NavigationDestination(
      icon: Icon(Icons.task_alt_outlined),
      selectedIcon: Icon(Icons.task_alt_rounded),
      label: 'Tasks',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppRouter.getIndexForLocation(location);
    final showFab = currentIndex == 0 || currentIndex == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: child,
      floatingActionButton: showFab
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              onPressed: () => _showAddSheet(context),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(AppRouter.getLocationForIndex(index));
        },
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: AppColors.paleLavender,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations,
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
        AppRouter.addDocument,
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
        AppRouter.reminders,
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
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
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
