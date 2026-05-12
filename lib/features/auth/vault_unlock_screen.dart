import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Vault Unlock — 6-digit PIN entry to access the vault.
class VaultUnlockScreen extends StatefulWidget {
  const VaultUnlockScreen({super.key});

  @override
  State<VaultUnlockScreen> createState() => _VaultUnlockScreenState();
}

class _VaultUnlockScreenState extends State<VaultUnlockScreen> {
  final List<bool> _filled = List.filled(6, false);
  String _pin = '';

  void _tap(String digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += digit;
      _filled[_pin.length - 1] = true;
    });
    if (_pin.length == 6) {
      Future.delayed(const Duration(milliseconds: 200),
          () => context.go(AppRouter.home));
    }
  }

  void _delete() {
    if (_pin.isEmpty) return;
    setState(() {
      _filled[_pin.length - 1] = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      child: Column(
        children: [
          const SizedBox(height: 48),
          const AuthLogo(),
          const SizedBox(height: 8),
          const Text('Enter your PIN',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('6-digit vault PIN',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
          const SizedBox(height: 28),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _filled[i]
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
              );
            }),
          ),
          const SizedBox(height: 36),
          // Numpad
          AuthCard(
            child: _NumPad(onDigit: _tap, onDelete: _delete),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => context.push(AppRouter.recoveryKey),
            child: const Text("Forgot PIN? Use recovery key",
                style:
                    TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  const _NumPad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((k) {
            if (k.isEmpty) return const SizedBox(width: 60, height: 52);
            return GestureDetector(
              onTap: () =>
                  k == '<' ? onDelete() : onDigit(k),
              child: Container(
                width: 60,
                height: 52,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paleLavender,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: k == '<'
                      ? const Icon(Icons.backspace_outlined,
                          color: AppColors.royalPurple, size: 20)
                      : Text(k,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
