import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Create Account Screen.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
                const Text('Create account',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Set up your private vault',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                AuthTextField(
                    label: 'Full name',
                    hint: 'Alex Morgan',
                    controller: _nameCtrl),
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                ),
                AuthTextField(
                  label: 'Password',
                  hint: '8+ characters',
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
                AuthTextField(
                  label: 'Confirm password',
                  hint: 'Repeat password',
                  obscure: true,
                  controller: _confirmCtrl,
                ),
                const SizedBox(height: 4),
                AuthPrimaryButton(
                  label: 'Create account',
                  onPressed: () => context.push(AppRouter.verifyEmail),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        context.push(AppRouter.signIn),
                    child: const Text('Already have an account? Sign in',
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
