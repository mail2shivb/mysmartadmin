import 'package:flutter/material.dart';
import 'screens/auth.dart';
import 'screens/main_screens.dart';
import 'screens/reminders.dart';
import 'screens/reports.dart';
import 'screens/family.dart';
import 'screens/misc.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const SplashScreen(),
  '/onboarding': (_) => const OnboardingScreen(),
  '/auth-choice': (_) => const AuthChoiceScreen(),
  '/sign-in': (_) => const SignInScreen(),
  '/create-account': (_) => const CreateAccountScreen(),
  '/email-verification': (_) => const EmailVerificationScreen(),
  '/mobile-verification': (_) => const MobileVerificationScreen(),
  '/mfa-setup': (_) => const MfaSetupScreen(),
  '/mfa-verification': (_) => const MfaVerificationScreen(),
  '/biometric-unlock': (_) => const BiometricUnlockScreen(),
  '/vault-unlock': (_) => const VaultUnlockScreen(),
  '/recovery-key': (_) => const RecoveryKeyScreen(),
  '/backup-codes': (_) => const BackupCodesScreen(),
  '/forgot-password': (_) => const ForgotPasswordScreen(),
  '/reset-password': (_) => const ResetPasswordScreen(),
  '/trusted-device': (_) => const TrustedDeviceScreen(),
  '/session-locked': (_) => const SessionLockedScreen(),
  '/security-settings': (_) => const SecuritySettingsScreen(),

  '/home': (_) => const HomeDashboardScreen(),
  '/vault': (_) => const VaultExplorerScreen(),
  '/category-detail': (_) => const CategoryDetailScreen(),
  '/search': (_) => const SearchResultsScreen(),
  '/add-record': (_) => const AddRecordScreen(),
  '/review-extraction': (_) => const ReviewExtractionScreen(),
  '/record-detail': (_) => const RecordDetailScreen(),
  '/edit-record': (_) => const EditRecordScreen(),
  '/replace-renew-record': (_) => const ReplaceRenewRecordScreen(),
  '/version-history': (_) => const VersionHistoryScreen(),
  '/review-queue': (_) => const ReviewQueueScreen(),

  '/reminders': (_) => const RemindersTasksScreen(),
  '/add-reminder': (_) => const AddReminderScreen(),
  '/reminder-detail': (_) => const ReminderDetailScreen(),
  '/tasks': (_) => const TasksScreen(),
  '/add-task': (_) => const AddTaskScreen(),
  '/task-detail': (_) => const TaskDetailScreen(),

  '/reports': (_) => const ReportsScreen(),
  '/report-detail': (_) => const ReportDetailScreen(),
  '/life-timeline': (_) => const LifeTimelineScreen(),

  '/family-admin': (_) => const FamilyAdminScreen(),
  '/family-group-detail': (_) => const FamilyGroupDetailScreen(),
  '/add-shared': (_) => const AddSharedItemScreen(),
  '/shared-item-detail': (_) => const SharedItemDetailScreen(),

  '/emergency-pack': (_) => const EmergencyPackScreen(),
  '/backup-export': (_) => const BackupExportScreen(),
  '/provider-contacts': (_) => const ProviderContactsScreen(),
  '/profile': (_) => const ProfileScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/help-about': (_) => const HelpAboutScreen(),

  '/perm-notifications': (_) => const NotificationPermissionScreen(),
  '/perm-camera': (_) => const CameraPermissionScreen(),
  '/perm-files': (_) => const FilePermissionScreen(),
  '/perm-biometric': (_) => const BiometricPermissionScreen(),

  '/state-loading': (_) => const LoadingStateScreen(),
  '/state-error': (_) => const ErrorStateScreen(),
  '/state-empty': (_) => const EmptyStateScreen(),
};
