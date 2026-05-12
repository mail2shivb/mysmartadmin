import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// MFA Setup — configure authenticator app for two-factor auth.
class MfaSetupScreen extends StatelessWidget {
  const MfaSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const AuthLogo(),
          const SizedBox(height: 32),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set up two-factor auth',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Scan the QR code with your authenticator app (Google Authenticator, Authy, etc.).',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                // QR code placeholder
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.paleLavender,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        size: 100, color: AppColors.royalPurple),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paleLavender,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LEDGERAI-XXXXXXXX-SECRET-KEY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.royalPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  label: 'I have scanned it — continue',
                  onPressed: () =>
                      context.push(AppRouter.backupCodes),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRouter.home),
                    child: const Text('Skip for now',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
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
