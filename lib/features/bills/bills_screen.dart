// B4.3 STATUS: IMPLEMENTED (Clean Stub)

import 'package:flutter/material.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/empty_state_widget.dart';
import '../../core/ui/tokens.dart';

/// Bills management screen (placeholder)
/// 
/// Will be implemented in future features phase.
/// Currently shows empty state with consistent styling.
class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      body: Padding(
        padding: AppPadding.screen,
        child: const EmptyStateWidget(
          icon: Icons.receipt_outlined,
          title: 'Stay on top of regular payments',
          description:
              'This is where you will track recurring bills, see what is due next, and keep a clear payment record on this device. It will help you stay organised and avoid missed household payments.',
        ),
      ),
    );
  }
}
