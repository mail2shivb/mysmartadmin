import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/database_provider.dart';
import '../../../core/ui/components/app_scaffold.dart';
import '../../../core/ui/components/empty_state_widget.dart';
import '../../../core/ui/components/section_header.dart';
import '../../../core/ui/tokens.dart';
import 'driving_licence_view_model.dart';

/// Lists all driving licence records, sorted by photocard expiry (soonest first).
///
/// Refreshes automatically when the add-licence form screen is popped.
class DrivingLicenceListScreen extends StatefulWidget {
  const DrivingLicenceListScreen({super.key});

  @override
  State<DrivingLicenceListScreen> createState() =>
      _DrivingLicenceListScreenState();
}

class _DrivingLicenceListScreenState extends State<DrivingLicenceListScreen> {
  late Future<List<DrivingLicenceDoc>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future =
          DrivingLicenceViewModel(DatabaseProvider.instance).loadLicences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Driving Licences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add driving licence',
            onPressed: () => context
                .push(AppRouter.drivingLicenceAdd)
                .then((_) => _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<DrivingLicenceDoc>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: AppPadding.screen,
              child: EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could not load licences',
                description: snapshot.error.toString(),
              ),
            );
          }

          final licences = snapshot.data ?? [];

          if (licences.isEmpty) {
            return const Padding(
              padding: AppPadding.screen,
              child: EmptyStateWidget(
                icon: Icons.directions_car_outlined,
                title: 'No driving licences recorded yet',
                description:
                    'Tap + to add a driving licence. Photocard expiry dates '
                    'are tracked so you always know when to renew.',
              ),
            );
          }

          return ListView(
            padding: AppPadding.screen,
            children: [
              const SectionHeader(title: 'Your Driving Licences'),
              const SizedBox(height: AppSpacing.sm),
              ...licences.map((l) => _LicenceCard(licence: l)),
            ],
          );
        },
      ),
    );
  }
}

// ── Licence card ───────────────────────────────────────────────────────────────

class _LicenceCard extends StatelessWidget {
  final DrivingLicenceDoc licence;

  const _LicenceCard({required this.licence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doc = licence.document;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.12),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppPadding.card,
        child: Row(
          children: [
            // Icon badge
            Container(
              width: AppSizes.avatarSmall,
              height: AppSizes.avatarSmall,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: AppSizes.iconMedium,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Title, licence number, categories, expiry badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  if (licence.licenceNumber != null)
                    Text(
                      'No. ${licence.licenceNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (licence.categories != null &&
                      licence.categories!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Categories: ${licence.categories}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (doc.expiryDate != null) ...[
                    const SizedBox(height: 6),
                    _ExpiryBadge(
                      status: licence.expiryStatus,
                      expiryDate: doc.expiryDate!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expiry badge ───────────────────────────────────────────────────────────────

class _ExpiryBadge extends StatelessWidget {
  final DrivingLicenceExpiryStatus status;
  final DateTime expiryDate;

  const _ExpiryBadge({required this.status, required this.expiryDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color color;
    final String label;

    switch (status) {
      case DrivingLicenceExpiryStatus.valid:
        color = Colors.green.shade600;
        label = 'Valid until ${_formatDate(expiryDate)}';
      case DrivingLicenceExpiryStatus.expiringSoon:
        color = Colors.orange.shade700;
        label = 'Expiring ${_formatDate(expiryDate)}';
      case DrivingLicenceExpiryStatus.expired:
        color = theme.colorScheme.error;
        label = 'Expired ${_formatDate(expiryDate)}';
      case DrivingLicenceExpiryStatus.unknown:
        color = theme.colorScheme.onSurfaceVariant;
        label = 'No expiry recorded';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
