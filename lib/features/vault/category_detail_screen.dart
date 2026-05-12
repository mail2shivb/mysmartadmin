import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/l_widgets.dart';

/// Category Detail — lists DocumentEntity rows for a given domainId.
/// Returns content only — ShellScaffold provides the gradient header + back button.
class CategoryDetailScreen extends StatelessWidget {
  final String domainId;
  const CategoryDetailScreen({super.key, required this.domainId});

  static const _labels = <String, String>{
    'identity_legal':                'Identity & Legal',
    'home_property':                 'Home & Property',
    'vehicles_transport':            'Vehicles & Transport',
    'banking_credit_borrowing':      'Banking & Credit',
    'banking_credit':                'Banking & Credit',
    'insurance_protection':          'Insurance',
    'insurance':                     'Insurance',
    'bills_utilities_subscriptions': 'Bills & Utilities',
    'bills_utilities':               'Bills & Utilities',
    'work_income_tax':               'Work & Income',
    'person_family':                 'People & Family',
  };

  static const _icons = <String, IconData>{
    'identity_legal':                Icons.badge_outlined,
    'home_property':                 Icons.home_outlined,
    'vehicles_transport':            Icons.directions_car_outlined,
    'banking_credit_borrowing':      Icons.account_balance_outlined,
    'banking_credit':                Icons.account_balance_outlined,
    'insurance_protection':          Icons.shield_outlined,
    'insurance':                     Icons.shield_outlined,
    'bills_utilities_subscriptions': Icons.receipt_long_outlined,
    'bills_utilities':               Icons.receipt_long_outlined,
    'work_income_tax':               Icons.work_outline,
    'person_family':                 Icons.group_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final title = _labels[domainId] ?? domainId.replaceAll('_', ' ');
    final icon = _icons[domainId] ?? Icons.folder_outlined;

    return FutureBuilder<List<DocumentEntity>>(
      future: _loadDocuments(db),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                  color: AppColors.primaryPurple, strokeWidth: 2),
            ),
          );
        }
        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              LEmptyState(
                icon: icon,
                title: 'No $title records yet',
                message: 'Records you add in this category will appear here.',
              ),
            ],
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: docs.length,
          separatorBuilder: (context2, index2) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = docs[i];
            return LCard(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: ListRow(
                icon: icon,
                title: doc.title,
                subtitle: doc.documentTypeId,
                badge: StatusBadge(
                  kind: _badgeKind(doc.expiryDate),
                  label: _statusLabel(doc.expiryDate),
                ),
                onTap: () =>
                    context.push(AppRouter.recordDetailPath(doc.id)),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<DocumentEntity>> _loadDocuments(AppDatabase db) async {
    final all = await db.documentsDao.getAllDocuments();
    return all.where((d) => d.domainId == domainId).toList();
  }

  String _statusLabel(DateTime? expiry) {
    if (expiry == null) return 'Active';
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Expired';
    if (diff == 0) return 'Today';
    if (diff <= 30) return '${diff}d left';
    return 'Valid';
  }

  BadgeKind _badgeKind(DateTime? expiry) {
    if (expiry == null) return BadgeKind.active;
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff < 0) return BadgeKind.urgent;
    if (diff <= 14) return BadgeKind.expiring;
    if (diff <= 30) return BadgeKind.review;
    return BadgeKind.active;
  }
}
