import 'package:flutter/material.dart';

import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Replace / Renew Record — upload a new version or update manually.
class ReplaceRecordScreen extends StatelessWidget {
  const ReplaceRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Replace / renew',
      subtitle: 'Upload latest version',
      onBack: () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Previous version',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  Text('Policy schedule – 18 Apr 2025',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LCard(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Column(
                children: const [
                  ListRow(
                    icon: Icons.upload_file_outlined,
                    title: 'Upload new document',
                  ),
                  Divider(height: 1, color: AppColors.divider),
                  ListRow(
                    icon: Icons.edit_note_outlined,
                    title: 'Update details manually',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LPrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
