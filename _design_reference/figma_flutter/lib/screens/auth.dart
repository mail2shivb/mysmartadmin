import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shell.dart';

void _go(BuildContext c, String r) => Navigator.of(c).pushNamed(r);
void _replace(BuildContext c, String r) => Navigator.of(c).pushReplacementNamed(r);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _replace(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.lavSurface, AppColors.bg]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleButton,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.royal.withOpacity(0.35), blurRadius: 36, offset: const Offset(0, 16))],
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              const Text('LedgerAI', style: TextStyle(color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w700)),
              const Text('Your private life-admin vault', style: TextStyle(color: AppColors.text2, fontSize: 14)),
              const SizedBox(height: 24),
              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.shield_outlined, 'Secure vault', 'Encrypted private storage'),
      (Icons.notifications_active_outlined, 'Smart reminders', 'Stay ahead of renewals'),
      (Icons.document_scanner_outlined, 'Scan or enter manually', 'Whatever fits you'),
      (Icons.group_outlined, 'Family admin', 'Share what matters'),
    ];
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(gradient: AppColors.purpleButton, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Your life admin, beautifully organised', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700, height: 1.25)),
          const SizedBox(height: 8),
          const Text('Store documents, track renewals, manage bills, and stay ahead of important life admin — securely and privately.',
              style: TextStyle(color: AppColors.text2, fontSize: 14)),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: features.map((f) => LCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.lavPale, borderRadius: BorderRadius.circular(12)),
                    child: Icon(f.$1, color: AppColors.royal, size: 18),
                  ),
                  const Spacer(),
                  Text(f.$2, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(f.$3, style: const TextStyle(color: AppColors.text2, fontSize: 11)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Get Started', onPressed: () => _go(context, '/auth-choice')),
          const SizedBox(height: 12),
          GhostButton(label: 'Explore Sample Vault', onPressed: () => _replace(context, '/home')),
        ],
      ),
    );
  }
}

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(gradient: AppColors.purpleButton, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Welcome to LedgerAI', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Your private life-admin vault, protected with secure sign-in.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.text2, fontSize: 14)),
          const SizedBox(height: 24),
          AuthCard(
            child: Column(
              children: [
                PrimaryButton(label: 'Sign In', onPressed: () => _go(context, '/sign-in')),
                const SizedBox(height: 12),
                GhostButton(label: 'Create Account', onPressed: () => _go(context, '/create-account')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _go(context, '/vault-unlock'),
                  child: const Text('Continue with local vault', style: TextStyle(color: AppColors.royal, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: const [
              SecureChip(label: 'Secure access'),
              SecureChip(label: 'Email verified'),
              SecureChip(label: 'Mobile verified'),
              SecureChip(label: 'MFA ready'),
              SecureChip(label: 'Biometric unlock'),
            ],
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('← Back', style: TextStyle(color: AppColors.royal))),
          const Text('Sign in securely', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Protected access to your private vault.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 18),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LField(label: 'Email or mobile number', hint: 'you@example.com'),
                const LField(label: 'Password', hint: 'Enter password', obscure: true),
                Row(children: [
                  Checkbox(value: false, onChanged: (_) {}),
                  const Text('Remember this device', style: TextStyle(color: AppColors.text2, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                PrimaryButton(label: 'Sign In', onPressed: () => _go(context, '/mfa-verification')),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => _go(context, '/forgot-password'), child: const Text('Forgot password?', style: TextStyle(color: AppColors.royal, fontSize: 12))),
                    TextButton(onPressed: () => _go(context, '/biometric-unlock'), child: const Text('Use biometrics', style: TextStyle(color: AppColors.royal, fontSize: 12))),
                  ],
                ),
                Center(child: TextButton(onPressed: () => _go(context, '/backup-codes'), child: const Text('Use recovery code', style: TextStyle(color: AppColors.text2, fontSize: 12)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('← Back', style: TextStyle(color: AppColors.royal))),
          const Text('Create your secure vault', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Premium privacy-first protection from the start.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 18),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LField(label: 'Full Name', hint: 'Shiv Patel'),
                const LField(label: 'Email Address', hint: 'you@example.com'),
                const LField(label: 'Mobile Number', hint: '+44 7700 900123'),
                const LField(label: 'Password', hint: 'Create a strong password', obscure: true),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.7,
                    minHeight: 6,
                    backgroundColor: AppColors.lavPale,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('✓ At least 12 characters\n✓ Mix of letters and numbers\n• Add a special character',
                    style: TextStyle(color: AppColors.text2, fontSize: 11, height: 1.6)),
                const SizedBox(height: 12),
                const LField(label: 'Confirm Password', hint: 'Re-enter password', obscure: true),
                Row(children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Expanded(child: Text('I agree to the Terms and Privacy Policy', style: TextStyle(color: AppColors.text2, fontSize: 12))),
                ]),
                Row(children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Text('Enable biometric unlock', style: TextStyle(color: AppColors.text2, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                PrimaryButton(label: 'Create Account', onPressed: () => _go(context, '/email-verification')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpScreenBase extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primary;
  final String next;
  final List<({String label, String? action})> actions;
  const _OtpScreenBase({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.next,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.lavPale, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.royal, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 18),
          AuthCard(
            child: Column(
              children: [
                const OTPInput(),
                const SizedBox(height: 16),
                PrimaryButton(label: primary, onPressed: () => _go(context, next)),
                const SizedBox(height: 10),
                Wrap(spacing: 16, alignment: WrapAlignment.center, children: actions.map((a) =>
                  TextButton(onPressed: () {}, child: Text(a.label, style: const TextStyle(color: AppColors.royal, fontSize: 12)))
                ).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});
  @override
  Widget build(BuildContext context) => const _OtpScreenBase(
    icon: Icons.mail_outline_rounded,
    title: 'Verify your email',
    subtitle: 'We sent a 6-digit code to s•••@example.com',
    primary: 'Verify Email',
    next: '/mobile-verification',
    actions: [(label: 'Resend code', action: null), (label: 'Change email', action: null)],
  );
}

class MobileVerificationScreen extends StatelessWidget {
  const MobileVerificationScreen({super.key});
  @override
  Widget build(BuildContext context) => const _OtpScreenBase(
    icon: Icons.phone_iphone_rounded,
    title: 'Verify your mobile number',
    subtitle: 'Code sent to +44 7700 900•••',
    primary: 'Verify Mobile',
    next: '/mfa-setup',
    actions: [(label: 'Resend SMS', action: null), (label: 'Change number', action: null), (label: 'Try email instead', action: null)],
  );
}

class MfaSetupScreen extends StatelessWidget {
  const MfaSetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final opts = [
      (Icons.smartphone_rounded, 'Authenticator App', 'Recommended', true),
      (Icons.mail_outline_rounded, 'Email Code', 'Receive a code via email', false),
      (Icons.sms_outlined, 'SMS / Mobile Code', 'Receive a code via SMS', false),
      (Icons.vpn_key_outlined, 'Recovery Codes', 'One-time backup codes', false),
      (Icons.fingerprint, 'Biometric Unlock', 'Face ID or Touch ID', false),
    ];
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Set up extra protection', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Add another layer of security to your vault.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 18),
          ...opts.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LCard(
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.lavPale, borderRadius: BorderRadius.circular(12)),
                    child: Icon(o.$1, color: AppColors.royal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(o.$2, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
                          if (o.$4) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(10)),
                              child: const Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ]),
                        Text(o.$3, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          )),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Continue Setup', onPressed: () => _go(context, '/recovery-key')),
        ],
      ),
    );
  }
}

class MfaVerificationScreen extends StatelessWidget {
  const MfaVerificationScreen({super.key});
  @override
  Widget build(BuildContext context) => const _OtpScreenBase(
    icon: Icons.shield_outlined,
    title: 'Extra verification',
    subtitle: 'Enter the 6-digit code from your authenticator app',
    primary: 'Verify & Continue',
    next: '/vault-unlock',
    actions: [(label: 'Try another method', action: null), (label: 'Resend code', action: null)],
  );
}

class BiometricUnlockScreen extends StatelessWidget {
  const BiometricUnlockScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              color: AppColors.lavPale,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lavBorder, width: 2, style: BorderStyle.solid),
            ),
            child: const Icon(Icons.fingerprint, color: AppColors.royal, size: 56),
          ),
          const SizedBox(height: 16),
          const Text('Unlock with biometrics', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Use Face ID, Touch ID, or fingerprint', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Unlock', onPressed: () => _replace(context, '/home')),
          const SizedBox(height: 12),
          GhostButton(label: 'Use passcode instead', onPressed: () => _go(context, '/vault-unlock')),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('Use recovery key', style: TextStyle(color: AppColors.royal))),
        ],
      ),
    );
  }
}

class VaultUnlockScreen extends StatelessWidget {
  const VaultUnlockScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final dots = [true, true, true, false];
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return AuthScaffold(
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.lavPale, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.royal, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('Unlock Vault', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const Text('Enter your secure passcode', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dots.map((on) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(color: on ? AppColors.primary : AppColors.lavBorder, shape: BoxShape.circle),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            children: keys.map((k) {
              return Container(
                decoration: k.isEmpty ? null : BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.lavBorder),
                ),
                child: Center(child: Text(k, style: const TextStyle(fontSize: 22, color: AppColors.text))),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            TextButton(onPressed: () => _go(context, '/biometric-unlock'), child: const Text('Use biometrics', style: TextStyle(color: AppColors.royal, fontSize: 12))),
            TextButton(onPressed: () {}, child: const Text('Use recovery key', style: TextStyle(color: AppColors.royal, fontSize: 12))),
          ]),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Unlock Vault', onPressed: () => _replace(context, '/home')),
        ],
      ),
    );
  }
}

class RecoveryKeyScreen extends StatelessWidget {
  const RecoveryKeyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Save your recovery key', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const Text('Use this key if you lose access to your devices.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lavSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lavBorder, style: BorderStyle.solid),
            ),
            child: const Text('L3DG-2026-AI-VAULT-7Q9P-HX4R-MN2B-K8T6',
                style: TextStyle(fontFamily: 'monospace', color: AppColors.deep, fontSize: 14, height: 1.8)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GhostButton(label: 'Copy', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: GhostButton(label: 'Download', onPressed: () {})),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Checkbox(value: false, onChanged: (_) {}),
            const Text('I have saved my recovery key', style: TextStyle(color: AppColors.text2, fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Continue', onPressed: () => _go(context, '/backup-codes')),
        ],
      ),
    );
  }
}

class BackupCodesScreen extends StatelessWidget {
  const BackupCodesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final codes = ['7Q9P-HX4R','MN2B-K8T6','V3LM-W2KE','RT5Z-9XAB','P1NQ-DH8L','BG4T-7CWR','KF8M-2YHN','XJ3R-PV6T'];
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Backup codes', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const Text('Each code works once. Keep them somewhere safe.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8, mainAxisSpacing: 8,
            childAspectRatio: 4,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            children: codes.map((c) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lavSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lavBorder),
              ),
              alignment: Alignment.center,
              child: Text(c, style: const TextStyle(fontFamily: 'monospace', color: AppColors.deep, fontSize: 13)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GhostButton(label: 'Copy', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: GhostButton(label: 'Download PDF', onPressed: () {})),
          ]),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('Regenerate codes', style: TextStyle(color: AppColors.royal))),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Saved — Continue', onPressed: () => _replace(context, '/home')),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('← Back', style: TextStyle(color: AppColors.royal))),
          const Text('Forgot password', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const Text("We'll send a recovery code to verify it's you.", style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 14),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LField(label: 'Email or mobile', hint: 'you@example.com'),
                PrimaryButton(label: 'Send recovery code', onPressed: () => _go(context, '/email-verification')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reset password', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
          const Text('Choose a new strong password.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 14),
          AuthCard(
            child: Column(
              children: [
                const LField(label: 'New password', obscure: true),
                const LField(label: 'Confirm password', obscure: true),
                PrimaryButton(label: 'Reset password', onPressed: () => _go(context, '/mfa-verification')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrustedDeviceScreen extends StatelessWidget {
  const TrustedDeviceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.lavPale, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.smartphone_rounded, color: AppColors.royal, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('Trust this device?', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('iPhone 15 Pro', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
                const Text('London, UK • New device', style: TextStyle(color: AppColors.text2, fontSize: 12)),
                const SizedBox(height: 12),
                Row(children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Text('Trust for 30 days', style: TextStyle(color: AppColors.text2, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                PrimaryButton(label: 'Trust this device', onPressed: () => _replace(context, '/home')),
                const SizedBox(height: 8),
                TextButton(onPressed: () => _replace(context, '/home'), child: const Text('Not now', style: TextStyle(color: AppColors.royal))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SessionLockedScreen extends StatelessWidget {
  const SessionLockedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 36),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.lavPale, shape: BoxShape.circle),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.royal, size: 40),
          ),
          const SizedBox(height: 12),
          const Text('Vault locked', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const Text('Your secure session has timed out.', style: TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Unlock with biometrics', onPressed: () => _go(context, '/biometric-unlock')),
          const SizedBox(height: 12),
          GhostButton(label: 'Use passcode', onPressed: () => _go(context, '/vault-unlock')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/auth-choice', (_) => false),
            child: const Text('Sign out', style: TextStyle(color: AppColors.urgent)),
          ),
        ],
      ),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Change password', 'Last changed 3 months ago'),
      ('Change vault PIN', 'Numeric vault passcode'),
      ('App lock', 'Auto-lock after inactivity'),
      ('Biometric unlock', 'Face ID enabled'),
      ('MFA settings', 'Authenticator app + SMS'),
      ('Trusted devices', '2 devices trusted'),
      ('Recovery key', 'Saved 12 Mar 2026'),
      ('Backup codes', '8 unused codes'),
      ('Auto-lock timer', '1 minute'),
      ('Session timeout', '15 minutes'),
      ('Privacy screen', 'Hide content in app switcher'),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: SimpleHeader(title: 'Security', subtitle: 'Protected access to your vault.', onBack: () => Navigator.pop(context)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...items.map((it) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LCard(
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(it.$1, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(it.$2, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ]),
            ),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE3E3),
                foregroundColor: AppColors.urgent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text('Delete vault'),
            ),
          ),
        ],
      ),
    );
  }
}
