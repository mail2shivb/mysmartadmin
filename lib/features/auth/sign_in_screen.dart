import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Sign In Screen.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

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
                const Text('Sign in',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Welcome back',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                ),
                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  obscure: _obscure,
                  controller: _passCtrl,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?',
                        style: TextStyle(
                            color: AppColors.royalPurple, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 4),
                AuthPrimaryButton(
                  label: 'Sign in',
                  onPressed: () => context.push(AppRouter.mfaVerify),
                ),
                const SizedBox(height: 12),
                const _Divider(),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        context.push(AppRouter.createAccount),
                    child: const Text("Don't have an account? Create one",
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(
              child: Divider(color: AppColors.divider, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or',
                style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 12)),
          ),
          const Expanded(
              child: Divider(color: AppColors.divider, thickness: 1)),
        ],
      );
}
