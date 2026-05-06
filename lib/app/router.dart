import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shell_scaffold.dart';
import '../presentation/screens/dashboard_screen.dart' as b13;
import '../presentation/screens/reminders_screen.dart' as b13;
import '../presentation/screens/reports_screen.dart' as b13;
import '../presentation/screens/policies_screen.dart' as b13;
import '../features/bills/bills_screen.dart';
import '../features/documents/documents_functional_screen.dart';
import '../features/documents/add_document_screen.dart';
import '../features/documents/document_types.dart';
import '../features/documents/driving_licence/driving_licence_list_screen.dart';
import '../features/documents/passport/passport_list_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/settings/settings_screen.dart';

/// Application router configuration using go_router
/// 
/// Routes:
/// - /home - Dashboard
/// - /bills - Bills
/// - /documents - Documents
/// - /reminders - Reminders
/// - /reports - Reports (accessible via navigation, not in bottom nav)
/// - /policies - Policies (accessible via navigation, not in bottom nav)
/// - /tasks - Tasks
/// - /settings - Settings (full screen, not in bottom nav)
/// 
/// Bottom nav tabs (5):
/// Dashboard, Bills, Documents, Reminders, Tasks
class AppRouter {
  AppRouter._();

  /// Root navigator key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Shell navigator key (for bottom nav)
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Route paths
  static const String home = '/home';
  static const String bills = '/bills';
  static const String documents = '/documents';
  static const String reminders = '/reminders';
  static const String reports = '/reports';
  static const String policies = '/policies';
  static const String categories = '/categories';
  static const String query = '/query';
  static const String tasks = '/tasks';
  static const String settings = '/settings';
  static const String passportList = '/passport';
  static const String passportAdd = '/passport/add';
  static const String drivingLicenceList = '/driving-licence';
  static const String drivingLicenceAdd = '/driving-licence/add';
  /// Untyped entry point — shows the document-type selector first.
  static const String addDocument = '/documents/add';

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
          // Dashboard tab (B13)
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: b13.DashboardScreen(),
            ),
          ),
          
          // Bills tab
          GoRoute(
            path: bills,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BillsScreen(),
            ),
          ),
          
          // Documents tab
          GoRoute(
            path: documents,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentsFunctionalScreen(),
            ),
          ),
          
          // Reminders tab (B13)
          GoRoute(
            path: reminders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: b13.RemindersScreen(),
            ),
          ),
          
          // Reports tab (B13)
          GoRoute(
            path: reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: b13.ReportsScreen(),
            ),
          ),
          
          // Policies tab (B13)
          GoRoute(
            path: policies,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: b13.PoliciesScreen(),
            ),
          ),
          
          // Tasks tab (keep existing)
          GoRoute(
            path: tasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasksScreen(),
            ),
          ),

          // Passport list (in shell — no bottom nav slot, reached from Documents)
          GoRoute(
            path: passportList,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PassportListScreen(),
            ),
          ),

          // Driving licence list (in shell — no bottom nav slot)
          GoRoute(
            path: drivingLicenceList,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DrivingLicenceListScreen(),
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

      // Passport add — pre-selects passport type in the unified form.
      GoRoute(
        path: passportAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(
          initialType: SupportedDocumentType.passport,
        ),
      ),

      // Driving licence add — pre-selects driving licence type in the unified form.
      GoRoute(
        path: drivingLicenceAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(
          initialType: SupportedDocumentType.drivingLicence,
        ),
      ),

      // Untyped entry point — shows type selector first (e.g. from Documents hub FAB).
      GoRoute(
        path: addDocument,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(),
      ),
    ],
  );

  /// Get the bottom nav index for a given location
  static int getIndexForLocation(String location) {
    switch (location) {
      case home:
        return 0;
      case bills:
        return 1;
      case documents:
        return 2;
      case reminders:
        return 3;
      case tasks:
        return 4;
      // reports and policies are accessible routes but not in bottom nav
      case reports:
      case policies:
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
        return bills;
      case 2:
        return documents;
      case 3:
        return reminders;
      case 4:
        return tasks;
      default:
        return home;
    }
  }
}

