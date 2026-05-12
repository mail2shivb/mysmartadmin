import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Backup Codes — display one-time recovery codes to store safely.
class BackupCodesScreen extends StatelessWidget {
  const BackupCodesScreen({super.key});

  static const _codes = [
    'LEDG-A3K7', 'LEDG-B8P2', 'LEDG-C5M9', 'LEDG-D1Q4',
    'LEDG-E6N3', 'LEDG-F2X8', 'LEDG-G9T5', 'LEDG-H4W1',
  ];

  @override
  Widget build(BuildContext context) {
    final codeText = _codes.join('\n');

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
                const Text('Save your backup codes',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Store these in a safe place. Each code can only be used once if you lose access to your authenticator.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paleLavender,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: _codes
                        .map((c) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3),
                              child: Text(c,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 15,
                                      color: AppColors.royalPurple,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: codeText));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text('Codes copied!')));
                        },
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.royalPurple,
                          side: const BorderSide(
                              color: AppColors.royalPurple),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: const Text('Download'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.royalPurple,
                          side: const BorderSide(
                              color: AppColors.royalPurple),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AuthPrimaryButton(
                  label: 'I have saved them — continue',
                  onPressed: () => context.go(AppRouter.home),
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
