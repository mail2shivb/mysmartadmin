import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shell_scaffold.dart';
import '../presentation/screens/policies_screen.dart' as b13;
import '../features/reports/reports_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/bills/bills_screen.dart';
import '../features/documents/documents_hub_screen.dart';
import '../features/documents/add_document_screen.dart';
import '../features/documents/document_types.dart';
import '../features/documents/driving_licence/driving_licence_list_screen.dart';
import '../features/documents/passport/passport_list_screen.dart';
import '../features/home/home_dashboard_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/vault/vault_explorer_screen.dart';
import '../features/vault/category_detail_screen.dart';
import '../features/search/search_screen.dart';

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
  static const String vault = '/vault';
  static const String vaultCategory = '/vault/category/:domainId';
  static const String search = '/search';
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
          // Dashboard tab — prototype HomeDashboardScreen
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeDashboardScreen(),
            ),
          ),
          
          // Bills tab
          GoRoute(
            path: bills,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BillsScreen(),
            ),
          ),
          
          // Documents tab — prototype hub layout
          GoRoute(
            path: documents,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentsHubScreen(),
            ),
          ),
          
          // Reminders tab — prototype RemindersScreen
          GoRoute(
            path: reminders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersScreen(),
            ),
          ),
          
          // Reports tab — prototype ReportsScreen
          GoRoute(
            path: reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
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

          // Vault explorer (in shell)
          GoRoute(
            path: vault,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VaultExplorerScreen(),
            ),
          ),

          // Category detail (in shell, reached from Vault)
          GoRoute(
            path: vaultCategory,
            pageBuilder: (context, state) {
              final domainId = state.pathParameters['domainId'] ?? '';
              return NoTransitionPage(
                child: CategoryDetailScreen(domainId: domainId),
              );
            },
          ),

          // Search (in shell)
          GoRoute(
            path: search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
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

  /// Get the bottom nav index for a given location.
  /// Layout: 0=Home, 1=Vault, 2=FAB(centre), 3=Reminders, 4=Reports
  static int getIndexForLocation(String location) {
    if (location.startsWith(home)) return 0;
    if (location.startsWith(vault)) return 1;
    if (location.startsWith(reminders)) return 3;
    if (location.startsWith(reports)) return 4;
    return 0;
  }

  /// Get the location for a given bottom nav index
  static String getLocationForIndex(int index) {
    switch (index) {
      case 0: return home;
      case 1: return vault;
      case 3: return reminders;
      case 4: return reports;
      default: return home;
    }
  }
}

