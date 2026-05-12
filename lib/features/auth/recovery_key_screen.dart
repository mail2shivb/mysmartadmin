import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Recovery Key — enter emergency recovery key to regain access.
class RecoveryKeyScreen extends StatelessWidget {
  const RecoveryKeyScreen({super.key});

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
                const Text('Recovery key',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Enter your 32-character recovery key to regain access to your vault.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.paleLavender,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    maxLines: 3,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX',
                      hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          letterSpacing: 0.5),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  label: 'Recover account',
                  onPressed: () => context.go(AppRouter.home),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Contact support',
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
