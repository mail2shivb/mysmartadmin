import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/database_provider.dart';
import '../../../core/ui/components/app_scaffold.dart';
import '../../../core/ui/components/empty_state_widget.dart';
import '../../../core/ui/components/section_header.dart';
import '../../../core/ui/tokens.dart';
import 'passport_view_model.dart';

/// Lists all passport records, sorted by expiry date (soonest first).
///
/// Refreshes automatically when the add-passport form screen is popped.
class PassportListScreen extends StatefulWidget {
  const PassportListScreen({super.key});

  @override
  State<PassportListScreen> createState() => _PassportListScreenState();
}

class _PassportListScreenState extends State<PassportListScreen> {
  late Future<List<PassportDoc>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = PassportViewModel(DatabaseProvider.instance).loadPassports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Passports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add passport',
            // Push the full-screen form; reload the list when it pops.
            onPressed: () =>
                context.push(AppRouter.passportAdd).then((_) => _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<PassportDoc>>(
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
                title: 'Could not load passports',
                description: snapshot.error.toString(),
              ),
            );
          }

          final passports = snapshot.data ?? [];

          if (passports.isEmpty) {
            return Padding(
              padding: AppPadding.screen,
              child: Column(
                children: [
                  const EmptyStateWidget(
                    icon: Icons.book_outlined,
                    title: 'No passports recorded yet',
                    description:
                        'Tap + to add a passport. Expiry dates are tracked '
                        'so you always know when to renew.',
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: AppPadding.screen,
            children: [
              const SectionHeader(title: 'Your Passports'),
              const SizedBox(height: AppSpacing.sm),
              ...passports.map((p) => _PassportCard(passport: p)),
            ],
          );
        },
      ),
    );
  }
}

// ── Passport card ──────────────────────────────────────────────────────────────

class _PassportCard extends StatelessWidget {
  final PassportDoc passport;

  const _PassportCard({required this.passport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doc = passport.document;

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
                Icons.book_outlined,
                size: AppSizes.iconMedium,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Title, passport number, expiry
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  if (passport.passportNumber != null)
                    Text(
                      'No. ${passport.passportNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (doc.expiryDate != null) ...[
                    const SizedBox(height: 6),
                    _ExpiryBadge(
                      status: passport.expiryStatus,
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
  final PassportExpiryStatus status;
  final DateTime expiryDate;

  const _ExpiryBadge({required this.status, required this.expiryDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color color;
    final String label;

    switch (status) {
      case PassportExpiryStatus.valid:
        color = Colors.green.shade600;
        label = 'Valid until ${_formatDate(expiryDate)}';
      case PassportExpiryStatus.expiringSoon:
        color = Colors.orange.shade700;
        label = 'Expiring ${_formatDate(expiryDate)}';
      case PassportExpiryStatus.expired:
        color = theme.colorScheme.error;
        label = 'Expired ${_formatDate(expiryDate)}';
      case PassportExpiryStatus.unknown:
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
