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
import '../features/records/add_shared_item_screen.dart';
import '../features/records/add_person_screen.dart';
import '../features/records/add_employment_screen.dart';
import '../features/records/add_address_screen.dart';
import '../features/tasks/add_task_screen.dart';
import '../features/assistant/assistant_chat_screen.dart';
import '../features/reminders/reminder_detail_screen.dart';
import '../features/reminders/add_reminder_screen.dart';
import '../features/reports/report_detail_screen.dart';
import '../features/reports/life_timeline_screen.dart';
// Auth screens
import '../features/auth/splash_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/create_account_screen.dart';
import '../features/auth/email_verification_screen.dart';
import '../features/auth/mobile_verification_screen.dart';
import '../features/auth/mfa_setup_screen.dart';
import '../features/auth/mfa_verification_screen.dart';
import '../features/auth/vault_unlock_screen.dart';
import '../features/auth/backup_codes_screen.dart';
import '../features/auth/recovery_key_screen.dart';

/// Application router.
///
/// Bottom nav tabs: Home | Vault | + (add) | Reminders | Reports
///
/// Architecture:
///  • ShellRoute  — renders ShellScaffold (gradient header + bottom nav).
///                  ALL screens that should show the bottom nav go here.
///  • Root routes — full-screen push (LScreen / AuthScaffold). No bottom nav.
///                  Used only for add/edit forms and auth screens.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // ── Tab paths ──────────────────────────────────────────────────────────
  static const String home = '/home';
  static const String vault = '/vault';
  static const String reminders = '/reminders';
  static const String reports = '/reports';

  // ── Shell sub-paths (have bottom nav) ──────────────────────────────────
  static const String vaultCategory = '/vault/category/:domainId';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String emergencyPack = '/emergency-pack';
  static const String recordDetail = '/records/detail';
  static const String versionHistory = '/records/version-history';
  static const String reminderDetail = '/reminders/detail';
  static const String reportDetail = '/reports/detail';
  static const String lifeTimeline = '/reports/life-timeline';
  static const String bills = '/bills';
  static const String documents = '/documents';
  static const String policies = '/policies';
  static const String tasks = '/tasks';
  static const String passportList = '/passport';
  static const String drivingLicenceList = '/driving-licence';

  // ── Root paths (no bottom nav — add/edit forms) ────────────────────────
  static const String addRecord = '/records/add';
  static const String editRecord = '/records/edit';
  static const String replaceRecord = '/records/replace';
  static const String addReminder = '/reminders/add';
  static const String passportAdd = '/passport/add';
  static const String drivingLicenceAdd = '/driving-licence/add';
  static const String addDocument = '/documents/add';
  static const String addTask = '/tasks/add';
  static const String addSharedItem = '/records/add-shared';
  static const String addPerson = '/records/add-person';
  static const String addEmployment = '/records/add-employment';
  static const String addAddress = '/records/add-address';
  static const String assistantChat = '/assistant';

  // ── Auth paths (no bottom nav) ─────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String createAccount = '/create-account';
  static const String verifyEmail = '/verify-email';
  static const String verifyMobile = '/verify-mobile';
  static const String mfaSetup = '/mfa-setup';
  static const String mfaVerify = '/mfa-verify';
  static const String vaultUnlock = '/vault-unlock';
  static const String backupCodes = '/backup-codes';
  static const String recoveryKey = '/recovery-key';

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: home,
    debugLogDiagnostics: false,
    routes: [
      // ── Shell (bottom nav visible) ─────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          // ── Tab screens ──────────────────────────────────────────────
          GoRoute(
            path: home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeDashboardScreen()),
          ),
          GoRoute(
            path: vault,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: VaultExplorerScreen()),
          ),
          GoRoute(
            path: reminders,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RemindersScreen()),
          ),
          GoRoute(
            path: reports,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsScreen()),
          ),

          // ── Shell sub-screens (push, bottom nav stays visible) ────────
          GoRoute(
            path: vaultCategory,
            pageBuilder: (context, state) {
              final domainId = state.pathParameters['domainId'] ?? '';
              return NoTransitionPage(
                  child: CategoryDetailScreen(domainId: domainId));
            },
          ),
          GoRoute(
            path: search,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: emergencyPack,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EmergencyPackScreen()),
          ),
          GoRoute(
            path: recordDetail,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RecordDetailScreen()),
          ),
          GoRoute(
            path: versionHistory,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: VersionHistoryScreen()),
          ),
          GoRoute(
            path: reminderDetail,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReminderDetailScreen()),
          ),
          GoRoute(
            path: reportDetail,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportDetailScreen()),
          ),
          GoRoute(
            path: lifeTimeline,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LifeTimelineScreen()),
          ),
          GoRoute(
            path: bills,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BillsScreen()),
          ),
          GoRoute(
            path: documents,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DocumentsHubScreen()),
          ),
          GoRoute(
            path: policies,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: b13.PoliciesScreen()),
          ),
          GoRoute(
            path: tasks,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TasksScreen()),
          ),
          GoRoute(
            path: passportList,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PassportListScreen()),
          ),
          GoRoute(
            path: drivingLicenceList,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DrivingLicenceListScreen()),
          ),
        ],
      ),

      // ── Root routes: add/edit forms (LScreen, no bottom nav) ───────────
      GoRoute(
        path: addRecord,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'manual';
          return AddRecordScreen(mode: mode);
        },
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
        path: addReminder,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddReminderScreen(),
      ),
      GoRoute(
        path: passportAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(
            initialType: SupportedDocumentType.passport),
      ),
      GoRoute(
        path: drivingLicenceAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(
            initialType: SupportedDocumentType.drivingLicence),
      ),
      GoRoute(
        path: addDocument,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDocumentScreen(),
      ),
      GoRoute(
        path: addTask,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: addSharedItem,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddSharedItemScreen(),
      ),
      GoRoute(
        path: addPerson,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddPersonScreen(),
      ),
      GoRoute(
        path: addEmployment,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEmploymentScreen(),
      ),
      GoRoute(
        path: addAddress,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: assistantChat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AssistantChatScreen(),
      ),

      // ── Auth routes (no bottom nav) ────────────────────────────────────
      GoRoute(
        path: splash,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: signIn,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: createAccount,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: verifyEmail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: verifyMobile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MobileVerificationScreen(),
      ),
      GoRoute(
        path: mfaSetup,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MfaSetupScreen(),
      ),
      GoRoute(
        path: mfaVerify,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MfaVerificationScreen(),
      ),
      GoRoute(
        path: vaultUnlock,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VaultUnlockScreen(),
      ),
      GoRoute(
        path: backupCodes,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BackupCodesScreen(),
      ),
      GoRoute(
        path: recoveryKey,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecoveryKeyScreen(),
      ),
    ],
  );

  /// Bottom nav index for a location.
  /// 0=Home, 1=Vault, 2=Add(fab), 3=Reminders, 4=Reports
  static int getIndexForLocation(String location) {
    if (location.startsWith(home)) return 0;
    if (location.startsWith(vault)) return 1;
    if (location.startsWith(reminders)) return 3;
    if (location.startsWith(reports)) return 4;
    return 0;
  }

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
