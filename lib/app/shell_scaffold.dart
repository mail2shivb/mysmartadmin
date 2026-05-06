// B4.3.1 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import '../core/ui/components/app_scaffold.dart';

/// Shell scaffold with bottom navigation bar
/// 
/// Features:
/// - Material 3 NavigationBar with 5 tabs
/// - Settings icon in AppBar for Home, Documents, and Tasks
/// - Tab switching updates routes correctly
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
    final currentIndex = AppRouter.getIndexForLocation(location);
    // Documents supplies its own AppBar (with inline add-mode toggle), so it
    // must not receive a second AppBar from ShellScaffold.
    final showAddAction = location == AppRouter.home;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBar = Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark 
              ? theme.colorScheme.outline.withOpacity(0.1)
              : theme.colorScheme.outline.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final targetLocation = AppRouter.getLocationForIndex(index);
          context.go(targetLocation);
        },
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_outlined),
            selectedIcon: Icon(Icons.receipt),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
        ],
      ),
    );
    
    if (!showAddAction) {
      return Scaffold(
        body: child,
        bottomNavigationBar: navBar,
      );
    }

    final title = location == AppRouter.documents ? 'Documents' : 'Dashboard';

    // Dashboard uses an inner SafeArea; remove top padding so AppBar spacing is consistent.
    final wrappedBody = location == AppRouter.home
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          )
        : child;

    return AppScaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      showAddAction: true,
      useSafeArea: false,
      body: wrappedBody,
      bottomNavigationBar: navBar,
    );
  }
}

