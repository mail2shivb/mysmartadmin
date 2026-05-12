import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _nameCtrl = TextEditingController();
  final _relationshipCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationshipCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add Person',
      subtitle: 'Person or family member profile',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                children: [
                  LField(label: 'Full name', hint: 'e.g. Jane Smith', controller: _nameCtrl),
                  LField(label: 'Relationship', hint: 'e.g. Partner, Child, Parent', controller: _relationshipCtrl),
                  LField(label: 'Notes', hint: 'Additional details…', controller: _notesCtrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.lock_outline, size: 13, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text('Saved locally in your private vault.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            LPrimaryButton(
              label: 'Save Person',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Person profile saved'),
                  behavior: SnackBarBehavior.floating,
                ));
                Navigator.of(context).maybePop();
              },
            ),
            const SizedBox(height: 8),
            LGhostButton(label: 'Cancel', onPressed: () => Navigator.of(context).maybePop()),
          ],
        ),
      ),
    );
  }
}
