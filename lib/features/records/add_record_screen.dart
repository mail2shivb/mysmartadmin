import 'package:flutter/material.dart';

import '../../shared/widgets/l_widgets.dart';

/// Add Record — manual entry form.
class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _providerCtrl.dispose();
    _referenceCtrl.dispose();
    _expiryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add record',
      subtitle: 'Manual entry',
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
                  LField(label: 'Title', hint: 'e.g. AXA Home Insurance', controller: _titleCtrl),
                  LField(label: 'Category', hint: 'Choose category', controller: _categoryCtrl),
                  LField(label: 'Provider', controller: _providerCtrl),
                  LField(label: 'Reference / policy number', controller: _referenceCtrl),
                  LField(label: 'Renewal / expiry date', controller: _expiryCtrl),
                  LField(label: 'Notes', controller: _notesCtrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LPrimaryButton(
              label: 'Save record',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 8),
            LGhostButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
