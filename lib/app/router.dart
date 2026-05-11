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
import '../features/home/emergency_pack_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/profile_screen.dart';
import '../features/vault/vault_explorer_screen.dart';
import '../features/vault/category_detail_screen.dart';
import '../features/search/search_screen.dart';
import '../features/records/add_record_screen.dart';
import '../features/records/record_detail_screen.dart';
import '../features/records/edit_record_screen.dart';
import '../features/records/replace_record_screen.dart';
import '../features/records/version_history_screen.dart';
import '../features/reminders/reminder_detail_screen.dart';
import '../features/reminders/add_reminder_screen.dart';
import '../features/reports/report_detail_screen.dart';
import '../features/reports/life_timeline_screen.dart';

/// Application router configuration using go_router
///
/// Bottom nav tabs (5):
/// Home | Vault | + (add) | Reminders | Reports
class AppRouter {
  AppRouter._();

  /// Root navigator key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Shell navigator key (for bottom nav)
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // ── Tab route paths ──────────────────────────────────────────────────────
  static const String home = '/home';
  static const String vault = '/vault';
  static const String reminders = '/reminders';
  static const String reports = '/reports';

  // ── Shell sub-routes (retain bottom nav) ────────────────────────────────
  static const String bills = '/bills';
  static const String documents = '/documents';
  static const String policies = '/policies';
  static const String tasks = '/tasks';

  // ── Root routes (push over shell — no bottom nav) ────────────────────────
  static const String vaultCategory = '/vault/category/:domainId';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String emergencyPack = '/emergency-pack';

  // ── Record routes ────────────────────────────────────────────────────────
  static const String addRecord = '/records/add';
  static const String recordDetail = '/records/detail';
  static const String editRecord = '/records/edit';
  static const String replaceRecord = '/records/replace';
  static const String versionHistory = '/records/version-history';

  // ── Reminder routes ──────────────────────────────────────────────────────
  static const String reminderDetail = '/reminders/detail';
  static const String addReminder = '/reminders/add';

  // ── Report routes ────────────────────────────────────────────────────────
  static const String reportDetail = '/reports/detail';
  static const String lifeTimeline = '/reports/life-timeline';

  // ── Document routes (legacy + new) ──────────────────────────────────────
  static const String passportList = '/passport';
  static const String passportAdd = '/passport/add';
  static const String drivingLicenceList = '/driving-licence';
  static const String drivingLicenceAdd = '/driving-licence/add';
  static const String addDocument = '/documents/add';

  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: home,
    debugLogDiagnostics: false,
    routes: [
      // ── Shell route (bottom nav) ─────────────────────────────────────────
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
              child: HomeDashboardScreen(),
            ),
          ),

          // Vault tab
          GoRoute(
            path: vault,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VaultExplorerScreen(),
            ),
          ),

          // Reminders tab
          GoRoute(
            path: reminders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersScreen(),
            ),
          ),

          // Reports tab
          GoRoute(
            path: reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),

          // Bills
          GoRoute(
            path: bills,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BillsScreen(),
            ),
          ),

          // Documents hub
          GoRoute(
            path: documents,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentsHubScreen(),
            ),
          ),

          // Policies
          GoRoute(
            path: policies,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: b13.PoliciesScreen(),
            ),
          ),

          // Tasks
          GoRoute(
            path: tasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasksScreen(),
            ),
          ),

          // Passport list (in shell)
          GoRoute(
            path: passportList,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PassportListScreen(),
            ),
          ),

          // Driving licence list (in shell)
          GoRoute(
            path: drivingLicenceList,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DrivingLicenceListScreen(),
            ),
          ),
        ],
      ),

      // ── Root routes (full-screen push, no bottom nav) ────────────────────

      // Category detail
      GoRoute(
        path: vaultCategory,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final domainId = state.pathParameters['domainId'] ?? '';
          return CategoryDetailScreen(domainId: domainId);
        },
      ),

      // Search
      GoRoute(
        path: search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),

      // Settings
      GoRoute(
        path: settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Profile
      GoRoute(
        path: profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Emergency pack
      GoRoute(
        path: emergencyPack,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmergencyPackScreen(),
      ),

      // ── Record routes ──────────────────────────────────────────────────
      GoRoute(
        path: addRecord,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddRecordScreen(),
      ),
      GoRoute(
        path: recordDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecordDetailScreen(),
      ),
      GoRoute(
        path: editRecord,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditRecordScreen(),
      ),
      GoRoute(
        path: replaceRecord,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReplaceRecordScreen(),
      ),
      GoRoute(
        path: versionHistory,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VersionHistoryScreen(),
      ),

      // ── Reminder routes ────────────────────────────────────────────────
      GoRoute(
        path: reminderDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReminderDetailScreen(),
      ),
      GoRoute(
        path: addReminder,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddReminderScreen(),
      ),

      // ── Report routes ──────────────────────────────────────────────────
      GoRoute(
        path: reportDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportDetailScreen(),
      ),
      GoRoute(
        path: lifeTimeline,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LifeTimelineScreen(),
      ),

      // ── Document / legacy routes ───────────────────────────────────────
      GoRoute(
        path: passportAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(
          initialType: SupportedDocumentType.passport,
        ),
      ),
      GoRoute(
        path: drivingLicenceAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(
          initialType: SupportedDocumentType.drivingLicence,
        ),
      ),
      GoRoute(
        path: addDocument,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(),
      ),
    ],
  );

  /// Bottom nav index for a given location.
  /// Layout: 0=Home, 1=Vault, 2=Add(fab), 3=Reminders, 4=Reports
  static int getIndexForLocation(String location) {
    if (location.startsWith(home)) return 0;
    if (location.startsWith(vault)) return 1;
    if (location.startsWith(reminders)) return 3;
    if (location.startsWith(reports)) return 4;
    return 0;
  }

  /// Route path for a given bottom nav index (skips index 2 = add fab).
  static String getLocationForIndex(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return vault;
      case 3:
        return reminders;
      case 4:
        return reports;
      default:
        return home;
    }
  }
}
