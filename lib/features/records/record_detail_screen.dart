import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

/// Record Detail — shows a record's key-value fields, attached documents,
/// and action buttons (Edit / Replace / Version history).
class RecordDetailScreen extends StatelessWidget {
  final String? recordId;

  const RecordDetailScreen({super.key, this.recordId});

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'AXA Home Insurance',
      subtitle: 'Insurance · Active',
      trailing: const _MoreIcon(),
      onBack: () => Navigator.of(context).maybePop(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          // ── Status badges ────────────────────────────────────────────────
          const Row(
            children: [
              StatusBadge(kind: BadgeKind.expiring, label: 'Expiring 22 May'),
              SizedBox(width: 8),
              StatusBadge(kind: BadgeKind.info, label: 'Renewal'),
            ],
          ),
          const SizedBox(height: 16),

          // ── Key-value details ────────────────────────────────────────────
          LCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _KV('Provider', 'AXA UK'),
                _KV('Policy number', 'AXA-882140-UK'),
                _KV('Cover', 'Buildings + Contents'),
                _KV('Renewal date', '22 May 2026'),
                _KV('Premium', '£42.18/month'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Attached documents ───────────────────────────────────────────
          const SectionTitle('Documents'),
          LCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: const [
                ListRow(
                  icon: Icons.description_outlined,
                  title: 'Policy schedule.pdf',
                  subtitle: 'Uploaded 18 Apr',
                ),
                Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.image_outlined,
                  title: 'Cover summary.jpg',
                  subtitle: 'Uploaded 18 Apr',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Actions ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: LPrimaryButton(
                  label: 'Edit',
                  onPressed: () => context.push(AppRouter.editRecord),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LGhostButton(
                  label: 'Replace',
                  onPressed: () => context.push(AppRouter.replaceRecord),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LGhostButton(
            label: 'Version history',
            onPressed: () => context.push(AppRouter.versionHistory),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _MoreIcon extends StatelessWidget {
  const _MoreIcon();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(k,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
          ],
        ),
      );
}
