import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';

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
    
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final targetLocation = AppRouter.getLocationForIndex(index);
          context.go(targetLocation);
        },
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
  }
}

