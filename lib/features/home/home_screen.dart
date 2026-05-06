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
        title: const Text('MySmartAdmin'),
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
            'Keep important records clear, private, and easy to manage on this device. No cloud storage by default and no unnecessary noise.',
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
      title: 'Nothing urgent right now',
      subtitle: 'No tracked documents are due to expire soon',
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
          title: 'No documents stored yet',
          description:
              'Add your first document to start building a private record system for reminders, reference, and future insights.',
          primaryButtonLabel: 'Add your first document',
          onPrimaryButtonPressed: () {
            // TODO: Navigate to add document
          },
        ),
      ),
    );
  }
}
