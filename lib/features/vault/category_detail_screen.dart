import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/taxonomy/canonical_taxonomy.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/ledger_components.dart';
import '../../core/ui/tokens.dart';
import '../../data/local/app_database.dart';

/// Category Detail — lists all [DocumentEntity] rows for a given [domainId].
///
/// The [domainId] is a [DomainIds] constant. Passed as a GoRouter path
/// parameter: `/vault/category/:domainId`.
class CategoryDetailScreen extends StatelessWidget {
  final String domainId;
  const CategoryDetailScreen({super.key, required this.domainId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final db = DatabaseProvider.instance;

    final descriptor = canonicalDomains.firstWhere(
      (d) => d.id == domainId,
      orElse: () => DomainDescriptor(
        id: domainId,
        displayName: domainId,
        icon: Icons.folder_outlined,
        iconColor: (cs) => cs.onSurfaceVariant,
        iconBackground: (cs) => cs.surfaceContainer,
      ),
    );

    return AppScaffold(
      appBar: AppBar(
        title: Text(descriptor.displayName),
      ),
      enableScroll: true,
      body: FutureBuilder<List<DocumentEntity>>(
        future: _loadDocuments(db, domainId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: EmptyStateCard(
                icon: Icons.error_outline,
                heading: 'Could not load records',
                body: 'Please try again later.',
              ),
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return EmptyStateCard(
              icon: descriptor.icon,
              heading: 'No ${descriptor.displayName} records yet',
              body: 'Records you add in this category will appear here.',
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final expiryDate = doc.expiryDate;
              final statusLevel = _statusLevel(expiryDate);
              final statusLabel = _statusLabel(expiryDate);

              return ListRow(
                icon: descriptor.icon,
                iconColor: descriptor.iconColor(cs),
                iconBackground: descriptor.iconBackground(cs),
                title: doc.title,
                subtitle: doc.documentTypeId,
                trailing: StatusBadge(
                  label: statusLabel,
                  level: statusLevel,
                ),
                showDivider: i < docs.length - 1,
              );
            },
          );
        },
      ),
    );
  }

  Future<List<DocumentEntity>> _loadDocuments(
    AppDatabase db,
    String domainId,
  ) async {
    final all = await db.documentsDao.getAllDocuments();
    return all.where((d) => d.domainId == domainId).toList();
  }

  LedgerStatusLevel _statusLevel(DateTime? expiry) {
    if (expiry == null) return LedgerStatusLevel.neutral;
    final now = DateTime.now();
    final diff = expiry.difference(now).inDays;
    if (diff < 0) return LedgerStatusLevel.danger;
    if (diff <= 30) return LedgerStatusLevel.warning;
    if (diff <= 90) return LedgerStatusLevel.info;
    return LedgerStatusLevel.ok;
  }

  String _statusLabel(DateTime? expiry) {
    if (expiry == null) return 'Active';
    final now = DateTime.now();
    final diff = expiry.difference(now).inDays;
    if (diff < 0) return 'Expired';
    if (diff == 0) return 'Today';
    if (diff <= 30) return '${diff}d left';
    return 'Valid';
  }
}
