import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Onboarding — feature highlights before sign in / create account.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _features = [
    (
      Icons.lock_outline_rounded,
      'Fully private',
      'Everything stays on your device. No cloud, no tracking.',
    ),
    (
      Icons.notifications_active_outlined,
      'Never miss a deadline',
      'Automatic reminders for renewals, bills, and expirations.',
    ),
    (
      Icons.folder_outlined,
      'One place for everything',
      'Passports, insurance, subscriptions, documents — all organised.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 48),
          const AuthLogo(),
          const SizedBox(height: 40),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to LedgerAI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The private life admin app.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                for (final f in _features) ...[
                  _FeatureRow(icon: f.$1, title: f.$2, body: f.$3),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                AuthPrimaryButton(
                  label: 'Get started',
                  onPressed: () => context.push(AppRouter.signIn),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRouter.createAccount),
                    child: const Text(
                      "Don't have an account? Create one",
                      style: TextStyle(
                          color: AppColors.royalPurple, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _FeatureRow(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.paleLavender,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.royalPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(body,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
