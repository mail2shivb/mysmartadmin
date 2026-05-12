import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _line1Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postcodeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _cityCtrl.dispose();
    _postcodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add Address',
      subtitle: 'Address record',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                children: [
                  LField(label: 'Address line 1', hint: 'e.g. 12 Oak Street', controller: _line1Ctrl),
                  LField(label: 'City / Town', hint: 'e.g. London', controller: _cityCtrl),
                  LField(label: 'Postcode', hint: 'e.g. SW1A 1AA', controller: _postcodeCtrl),
                  LField(label: 'Notes', hint: 'Type of address (home, work, previous)…', controller: _notesCtrl),
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
              label: 'Save Address',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Address record saved'),
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
