import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';
import '../../shared/widgets/proto_empty_state.dart';

/// Category Detail — prototype PageScaffold style.
/// Lists [DocumentEntity] rows for a given [domainId].
class CategoryDetailScreen extends StatelessWidget {
  final String domainId;
  const CategoryDetailScreen({super.key, required this.domainId});

  static const _labels = <String, String>{
    'identity_legal':      'Identity & Legal',
    'home_property':       'Home & Property',
    'vehicles_transport':  'Vehicles',
    'banking_credit':      'Banking & Credit',
    'insurance':           'Insurance',
    'bills_utilities':     'Bills & Utilities',
    'work_income_tax':     'Work & Income',
    'person_family':       'People & Family',
  };

  static const _icons = <String, IconData>{
    'identity_legal':      Icons.badge_rounded,
    'home_property':       Icons.home_rounded,
    'vehicles_transport':  Icons.directions_car_rounded,
    'banking_credit':      Icons.account_balance_rounded,
    'insurance':           Icons.shield_rounded,
    'bills_utilities':     Icons.receipt_long_rounded,
    'work_income_tax':     Icons.work_rounded,
    'person_family':       Icons.people_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.instance;
    final title = _labels[domainId] ?? domainId;
    final icon  = _icons[domainId]  ?? Icons.folder_rounded;

    return PageScaffold(
      title: title,
      subtitle: 'Records in this category',
      showBack: true,
      child: FutureBuilder<List<DocumentEntity>>(
        future: _loadDocuments(db),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(ProtoSpacing.xxxl),
                child: CircularProgressIndicator(
                    color: AppColors.primaryPurple),
              ),
            );
          }
          if (snapshot.hasError) {
            return const ProtoEmptyState(
              icon: Icons.error_outline,
              title: 'Could not load records',
              message: 'Please try again later.',
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return ProtoEmptyState(
              icon: icon,
              title: 'No $title records yet',
              message: 'Records you add in this category will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(ProtoSpacing.lg),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final statusLabel = _statusLabel(doc.expiryDate);
              final statusColor = _statusColor(doc.expiryDate);
              return Padding(
                padding: const EdgeInsets.only(bottom: ProtoSpacing.sm),
                child: ProtoAppCard(
                  padding: const EdgeInsets.all(ProtoSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.paleLavender,
                          borderRadius:
                              BorderRadius.circular(ProtoRadius.md),
                        ),
                        child: Icon(icon,
                            color: AppColors.deepPurple, size: 20),
                      ),
                      const SizedBox(width: ProtoSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.title,
                                style: AppTextStyles.title
                                    .copyWith(fontSize: 15)),
                            if (doc.documentTypeId != null)
                              Text(doc.documentTypeId!,
                                  style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: ProtoSpacing.sm,
                            vertical: ProtoSpacing.xs),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(ProtoRadius.sm),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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

  Color _statusColor(DateTime? expiry) {
    if (expiry == null) return AppColors.success;
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff < 0) return AppColors.error;
    if (diff <= 30) return AppColors.warning;
    return AppColors.success;
  }
}
