// F2.1 STATUS: RE-IMPLEMENTED

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'reminders_screen.dart';
import 'reports_screen.dart';
import 'policies_screen.dart';
import '../widgets/add_entry_bottom_sheet.dart';

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
/// Bottom navigation is anchored with 1px top divider for visual separation.
/// SafeArea is applied INSIDE each screen to prevent status bar overlap.
/// Dashboard has a "+" action for adding new entries.
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
        actions: _currentIndex == 0 // Show "+" only on Dashboard
            ? [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  color: const Color(0xFF1E6FD9), // Primary blue - clearly visible on #F1F6FB
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const AddEntryBottomSheet(),
                    );
                  },
                  tooltip: 'Add entry',
                ),
              ]
            : null,
      ),
      body: _screens[_currentIndex], // SafeArea is INSIDE each screen
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Pure white
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant, // #E2E8F0
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Reminders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                activeIcon: Icon(Icons.shield),
                label: 'Policies',
              ),
            ],
          ),
        ),
      ),
    );
  }
}



