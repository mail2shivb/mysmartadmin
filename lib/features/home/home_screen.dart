import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/theme_inherited_widget.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/insight_card.dart';
import '../../core/ui/components/empty_state_widget.dart';

/// Home screen - main dashboard
/// 
/// Shows:
/// - Upcoming document expiries
/// - Important alerts
/// - Recent documents
/// 
/// AppBar includes settings icon
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('LedgerAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouter.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      enableScroll: true,
      padding: AppPadding.screen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Text(
            'Your Personal Record System',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'All your important documents, stored securely on your device. No cloud sync, no analytics.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Upcoming expiries section
          const SectionHeader(title: 'Upcoming Expiries'),
          const _EmptyExpiryState(),
          const SizedBox(height: AppSpacing.xl),

          // Recent documents section
          const SectionHeader(title: 'Recent Documents'),
          const _EmptyRecentState(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add document screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
      ),
    );
  }
}

class _EmptyExpiryState extends StatelessWidget {
  const _EmptyExpiryState();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeProvider.colorsOf(context);
    
    return InsightCard(
      leadingIcon: Icons.check_circle_outline,
      leadingIconColor: colors.success,
      leadingIconBackground: colors.successLight,
      title: 'All Clear',
      subtitle: 'No documents expiring soon',
    );
  }
}

class _EmptyRecentState extends StatelessWidget {
  const _EmptyRecentState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppPadding.card,
        child: EmptyStateWidget(
          icon: Icons.description_outlined,
          title: 'No Documents Yet',
          description:
              'Start by adding your first document. Everything stays private on your device.',
          primaryButtonLabel: 'Add Your First Document',
          onPrimaryButtonPressed: () {
            // TODO: Navigate to add document
          },
        ),
      ),
    );
  }
}
