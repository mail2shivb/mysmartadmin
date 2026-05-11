import 'package:flutter/material.dart';

import '../../shared/widgets/l_widgets.dart';

/// Add Reminder — form to create a new renewal, expiry, or payment reminder.
class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleCtrl = TextEditingController();
  final _linkedCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _repeatCtrl = TextEditingController();
  final _notifyCtrl = TextEditingController(text: '7 days before');
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkedCtrl.dispose();
    _dueDateCtrl.dispose();
    _repeatCtrl.dispose();
    _notifyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Add reminder',
      onBack: () => Navigator.of(context).maybePop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                children: [
                  LField(
                    label: 'Title',
                    hint: 'e.g. Renew car insurance',
                    controller: _titleCtrl,
                  ),
                  LField(
                    label: 'Linked record',
                    hint: 'Optional',
                    controller: _linkedCtrl,
                  ),
                  LField(label: 'Due date', controller: _dueDateCtrl),
                  LField(
                    label: 'Repeat',
                    hint: 'None / Weekly / Monthly / Yearly',
                    controller: _repeatCtrl,
                  ),
                  LField(
                    label: 'Notify me',
                    controller: _notifyCtrl,
                  ),
                  LField(label: 'Notes', controller: _notesCtrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LPrimaryButton(
              label: 'Save reminder',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
