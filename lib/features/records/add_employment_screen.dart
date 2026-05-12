import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

class AddEmploymentScreen extends StatefulWidget {
  const AddEmploymentScreen({super.key});

  @override
  State<AddEmploymentScreen> createState() => _AddEmploymentScreenState();
}

class _AddEmploymentScreenState extends State<AddEmploymentScreen> {
  final _employerCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _employerCtrl.dispose();
    _roleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add Employment',
      subtitle: 'Employment record',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                children: [
                  LField(label: 'Employer', hint: 'Company name', controller: _employerCtrl),
                  LField(label: 'Job title / Role', hint: 'e.g. Senior Developer', controller: _roleCtrl),
                  LField(label: 'Notes', hint: 'Contract type, salary, start date…', controller: _notesCtrl),
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
              label: 'Save Employment Record',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Employment record saved'),
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
