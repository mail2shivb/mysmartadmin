import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/empty_state_widget.dart';

/// Documents screen
/// 
/// Features:
/// - List/grid view of all documents
/// - Filters by domain/type
/// - Search (full-text search later)
/// - Sort options
/// 
/// AppBar includes settings icon
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Show sort options
            },
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouter.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      padding: AppPadding.screen,
      body: const EmptyStateWidget(
        icon: Icons.description_outlined,
        title: 'No Documents Yet',
        description:
            'Your documents are stored securely on this device only. Add your first document to get started.',
        primaryButtonLabel: 'Add Document',
        secondaryButtonLabel: 'Learn More',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add document screen
        },
        tooltip: 'Add Document',
        child: const Icon(Icons.add),
      ),
    );
  }
}
