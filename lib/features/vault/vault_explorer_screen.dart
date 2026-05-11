import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/taxonomy/canonical_taxonomy.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/ledger_components.dart';
import '../../core/ui/tokens.dart';

/// Vault Explorer — browse all domain categories.
///
/// Data comes from [canonicalDomains]; tapping a tile navigates to the
/// [CategoryDetailScreen] for that domain.
class VaultExplorerScreen extends StatelessWidget {
  const VaultExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Vault')),
      enableScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlackStyleHeader(
            title: 'Your Vault',
            subtitle: 'All your records in one place',
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.25,
              ),
              itemCount: canonicalDomains.length,
              itemBuilder: (context, i) {
                final domain = canonicalDomains[i];
                return _DomainTile(domain: domain);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _DomainTile extends StatelessWidget {
  final DomainDescriptor domain;
  const _DomainTile({required this.domain});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = domain.iconBackground(cs);
    final fg = domain.iconColor(cs);

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          if (domain.featureRoute != null) {
            context.go(domain.featureRoute!);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: cs.outlineVariant,
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(domain.icon, color: fg, size: 20),
              ),
              const Spacer(),
              Text(
                domain.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'View records',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
