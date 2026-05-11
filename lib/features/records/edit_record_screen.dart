import 'package:flutter/material.dart';

import '../../shared/widgets/l_widgets.dart';

/// Edit Record — pre-filled form for updating an existing record.
class EditRecordScreen extends StatefulWidget {
  const EditRecordScreen({super.key});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _titleCtrl = TextEditingController(text: 'AXA Home Insurance');
  final _providerCtrl = TextEditingController(text: 'AXA UK');
  final _referenceCtrl = TextEditingController(text: 'AXA-882140-UK');
  final _renewalCtrl = TextEditingController(text: '22 May 2026');
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _providerCtrl.dispose();
    _referenceCtrl.dispose();
    _renewalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Edit record',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                children: [
                  LField(label: 'Title', controller: _titleCtrl),
                  LField(label: 'Provider', controller: _providerCtrl),
                  LField(label: 'Policy number', controller: _referenceCtrl),
                  LField(label: 'Renewal date', controller: _renewalCtrl),
                  LField(label: 'Notes', controller: _notesCtrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LPrimaryButton(
              label: 'Save changes',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
