import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// MFA Verification — enter 6-digit code from authenticator app.
class MfaVerificationScreen extends StatelessWidget {
  const MfaVerificationScreen({super.key});

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
                const Text('Two-factor verification',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Enter the 6-digit code from your authenticator app.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                OtpRow(onCompleted: (code) {}),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'Verify',
                  onPressed: () => context.go(AppRouter.home),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRouter.recoveryKey),
                    child: const Text("Can't access your app? Use recovery key",
                        style: TextStyle(
                            color: AppColors.royalPurple, fontSize: 13)),
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
