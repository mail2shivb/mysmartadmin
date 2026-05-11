import 'package:flutter/material.dart';

import '../../shared/widgets/l_widgets.dart';

/// Profile Screen — editable user profile fields.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Alex Morgan');
  final _emailCtrl = TextEditingController(text: 'alex@example.co.uk');
  final _mobileCtrl = TextEditingController(text: '+44 7700 900123');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Profile',
      subtitle: 'Your details',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LField(label: 'Full name', controller: _nameCtrl),
                  LField(label: 'Email', controller: _emailCtrl),
                  LField(label: 'Mobile', controller: _mobileCtrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LPrimaryButton(
              label: 'Save profile',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
