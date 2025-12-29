// F1.6 STATUS: IMPLEMENTED

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'reminders_screen.dart';
import 'reports_screen.dart';
import 'policies_screen.dart';

/// Main app scaffold with bottom navigation
///
/// Provides navigation between main screens:
/// - Dashboard
/// - Reminders
/// - Reports
/// - Policies
///
/// Uses strong canvas + sheet model (Starling/Apple Wallet style).
/// Canvas background (#F1F6FB) with white card sheets floating above.
/// SafeArea is applied INSIDE each screen to prevent status bar overlap.
/// This is a dumb widget with no business logic.
class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const RemindersScreen(),
    const ReportsScreen(),
    const PoliciesScreen(),
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Reminders',
    'Reports',
    'Policies',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Shaded blue background
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      body: _screens[_currentIndex], // SafeArea is INSIDE each screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Policies',
          ),
        ],
      ),
    );
  }
}


