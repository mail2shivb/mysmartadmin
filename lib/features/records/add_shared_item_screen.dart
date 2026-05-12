import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

class AddSharedItemScreen extends StatefulWidget {
  const AddSharedItemScreen({super.key});

  @override
  State<AddSharedItemScreen> createState() => _AddSharedItemScreenState();
}

class _AddSharedItemScreenState extends State<AddSharedItemScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add Shared Item',
      subtitle: 'Share a record with someone',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                children: [
                  LField(label: 'Item title', hint: 'e.g. Joint home insurance', controller: _titleCtrl),
                  LField(label: 'Notes', hint: 'Details…', controller: _notesCtrl),
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
              label: 'Save Shared Item',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Shared item saved'),
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
