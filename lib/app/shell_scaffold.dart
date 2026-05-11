import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import '../shared/widgets/proto_bottom_nav_bar.dart';

/// Shell scaffold — wraps each tab with the prototype bottom nav.
/// Each screen owns its own header via PageScaffold (purple strip + white sheet).
class ShellScaffold extends StatelessWidget {
  final String location;
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppRouter.getIndexForLocation(location);

    return Scaffold(
      backgroundColor: Colors.white,
      body: child,
      bottomNavigationBar: ProtoBottomNavBar(
        currentIndex: currentIndex,
        onTabSelected: (index) {
          context.go(AppRouter.getLocationForIndex(index));
        },
        onAddPressed: () => _showAddSheet(context),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _AddActionSheet(),
    );
  }
}

class _AddActionSheet extends StatelessWidget {
  const _AddActionSheet();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.description_rounded, 'Add document',
          AppRouter.addDocument),
      (Icons.receipt_long_rounded, 'Add bill', AppRouter.bills),
      (Icons.notifications_rounded, 'Add reminder', AppRouter.reminders),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add new',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1233),
                )),
            const SizedBox(height: 16),
            for (final item in items)
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3ECFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1, color: const Color(0xFF7C3AED)),
                ),
                title: Text(item.$2,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.$3);
                },
              ),
          ],
        ),
      ),
    );
  }
}

