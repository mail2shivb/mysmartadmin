import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shell_scaffold.dart';
import '../features/home/home_screen.dart';
import '../features/documents/documents_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/query/query_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/settings/settings_screen.dart';

/// Application router configuration using go_router
/// 
/// Routes (exact):
/// - /home
/// - /documents
/// - /categories
/// - /query
/// - /tasks
/// - /settings
/// 
/// Bottom nav tabs (5):
/// Home, Documents, Categories, Query, Tasks
/// 
/// Settings accessible via AppBar icon
class AppRouter {
  AppRouter._();

  /// Root navigator key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Shell navigator key (for bottom nav)
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Route paths
  static const String home = '/home';
  static const String documents = '/documents';
  static const String categories = '/categories';
  static const String query = '/query';
  static const String tasks = '/tasks';
  static const String settings = '/settings';

  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: home,
    debugLogDiagnostics: false,
    routes: [
      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          // Home tab
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          
          // Documents tab
          GoRoute(
            path: documents,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentsScreen(),
            ),
          ),
          
          // Categories tab
          GoRoute(
            path: categories,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CategoriesScreen(),
            ),
          ),
          
          // Query tab
          GoRoute(
            path: query,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QueryScreen(),
            ),
          ),
          
          // Tasks tab
          GoRoute(
            path: tasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasksScreen(),
            ),
          ),
        ],
      ),
      
      // Settings (not in bottom nav)
      GoRoute(
        path: settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  /// Get the bottom nav index for a given location
  static int getIndexForLocation(String location) {
    switch (location) {
      case home:
        return 0;
      case documents:
        return 1;
      case categories:
        return 2;
      case query:
        return 3;
      case tasks:
        return 4;
      default:
        return 0;
    }
  }

  /// Get the location for a given bottom nav index
  static String getLocationForIndex(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return documents;
      case 2:
        return categories;
      case 3:
        return query;
      case 4:
        return tasks;
      default:
        return home;
    }
  }
}

