import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shell.dart';

const _categories = <({String label, IconData icon})>[
  (label: 'Identity', icon: Icons.badge_outlined),
  (label: 'Insurance', icon: Icons.shield_outlined),
  (label: 'Banking', icon: Icons.account_balance_outlined),
  (label: 'Utilities', icon: Icons.bolt_outlined),
  (label: 'Health', icon: Icons.favorite_border),
  (label: 'Vehicle', icon: Icons.directions_car_outlined),
  (label: 'Home', icon: Icons.home_outlined),
  (label: 'Family', icon: Icons.group_outlined),
  (label: 'Work', icon: Icons.work_outline),
  (label: 'Subscriptions', icon: Icons.subscriptions_outlined),
];

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeTab: 0,
      header: SlackStyleHeader(
        title: 'LedgerAI',
        subtitle: 'Welcome back, Alex',
        searchHint: 'Search records, reminders, tasks…',
        trailing: Row(children: const [
          HeaderIcon(icon: Icons.notifications_none_rounded),
          SizedBox(width: 8),
          HeaderIcon(icon: Icons.lock_outline_rounded),
        ]),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          RoundedContentSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Categories'),
                CategoryCarousel(items: _categories,
                    onTap: (label) => Navigator.pushNamed(context, '/category-detail', arguments: label)),
                const SizedBox(height: 14),
                const SectionTitle('Action needed'),
                LCard(child: Column(children: [
                  ListRow(
                    icon: Icons.shield_outlined,
                    title: 'AXA Home Insurance',
                    subtitle: 'Renewal due 22 May 2026',
                    badge: const StatusBadge(kind: BadgeKind.expiring, label: 'Expiring'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail'),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  ListRow(
                    icon: Icons.badge_outlined,
                    title: 'British Passport',
                    subtitle: 'Expires 14 Aug 2026',
                    badge: const StatusBadge(kind: BadgeKind.review, label: 'Review'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail'),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  ListRow(
                    icon: Icons.bolt_outlined,
                    title: 'Octopus Energy bill',
                    subtitle: 'Due 12 May 2026',
                    badge: const StatusBadge(kind: BadgeKind.due, label: 'Due'),
                    onTap: () => Navigator.pushNamed(context, '/reminder-detail'),
                  ),
                ])),
                const SizedBox(height: 14),
                const SectionTitle('Recent records'),
                LCard(child: Column(children: [
                  ListRow(
                    icon: Icons.account_balance_outlined,
                    title: 'Halifax current account',
                    subtitle: 'Updated 2 May',
                    badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail'),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  ListRow(
                    icon: Icons.shield_outlined,
                    title: 'Aviva car insurance',
                    subtitle: 'Updated 28 Apr',
                    badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail'),
                  ),
                ])),
                const SizedBox(height: 14),
                const SectionTitle('Quick actions'),
                Row(children: [
                  Expanded(child: GhostButton(label: 'Emergency pack', onPressed: () => Navigator.pushNamed(context, '/emergency-pack'))),
                  const SizedBox(width: 10),
                  Expanded(child: GhostButton(label: 'Family', onPressed: () => Navigator.pushNamed(context, '/family-admin'))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VaultExplorerScreen extends StatefulWidget {
  const VaultExplorerScreen({super.key});
  @override
  State<VaultExplorerScreen> createState() => _VaultExplorerScreenState();
}

class _VaultExplorerScreenState extends State<VaultExplorerScreen> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeTab: 1,
      header: SlackStyleHeader(
        title: 'Vault',
        subtitle: '112 records · all categories',
        searchHint: 'Search vault…',
        onBack: () => Navigator.pop(context),
        trailing: const HeaderIcon(icon: Icons.tune_rounded),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          RoundedContentSheet(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FilterChipRow(
                chips: const ['All', 'Active', 'Expiring', 'Review', 'Drafts'],
                active: _filter,
                onChange: (c) => setState(() => _filter = c),
              ),
              const SizedBox(height: 14),
              CategoryCarousel(items: _categories,
                  onTap: (label) => Navigator.pushNamed(context, '/category-detail', arguments: label)),
              const SizedBox(height: 14),
              const SectionTitle('All records'),
              LCard(child: Column(children: [
                ListRow(icon: Icons.badge_outlined, title: 'British Passport', subtitle: 'Identity · Expires 14 Aug 2026',
                    badge: const StatusBadge(kind: BadgeKind.expiring, label: 'Expiring'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail')),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(icon: Icons.account_balance_outlined, title: 'Halifax current account', subtitle: 'Banking · Updated 2 May',
                    badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail')),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(icon: Icons.shield_outlined, title: 'AXA Home Insurance', subtitle: 'Insurance · Renewal 22 May',
                    badge: const StatusBadge(kind: BadgeKind.expiring, label: 'Expiring'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail')),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(icon: Icons.directions_car_outlined, title: 'Aviva car insurance', subtitle: 'Insurance · Renewal 18 Sep',
                    badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail')),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy', subtitle: 'Utilities · Monthly',
                    badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail')),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(icon: Icons.subscriptions_outlined, title: 'Netflix', subtitle: 'Subscriptions · £10.99/mo',
                    badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                    onTap: () => Navigator.pushNamed(context, '/record-detail')),
              ])),
            ]),
          ),
        ],
      ),
    );
  }
}

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final label = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Insurance';
    return AppScaffold(
      header: SlackStyleHeader(
        title: label,
        subtitle: '$label records and reminders',
        searchHint: 'Search $label…',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle('Records'),
            LCard(child: Column(children: [
              ListRow(icon: Icons.shield_outlined, title: 'AXA Home Insurance', subtitle: 'Renewal 22 May',
                  badge: const StatusBadge(kind: BadgeKind.expiring, label: 'Expiring'),
                  onTap: () => Navigator.pushNamed(context, '/record-detail')),
              const Divider(height: 1, color: AppColors.divider),
              ListRow(icon: Icons.directions_car_outlined, title: 'Aviva car insurance', subtitle: 'Renewal 18 Sep',
                  badge: const StatusBadge(kind: BadgeKind.active, label: 'Active'),
                  onTap: () => Navigator.pushNamed(context, '/record-detail')),
            ])),
          ])),
        ],
      ),
    );
  }
}

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Search', searchHint: 'Type to search…', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Results for "passport"'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.badge_outlined, title: 'British Passport', subtitle: 'Identity · Expires 14 Aug 2026',
                onTap: () => Navigator.pushNamed(context, '/record-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.notifications_active_outlined, title: 'Renew passport', subtitle: 'Reminder · Due 14 May',
                onTap: () => Navigator.pushNamed(context, '/reminder-detail')),
          ])),
        ])),
      ]),
    );
  }
}

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Add record', subtitle: 'Manual entry', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            LField(label: 'Title', hint: 'e.g. AXA Home Insurance'),
            LField(label: 'Category', hint: 'Choose category'),
            LField(label: 'Provider'),
            LField(label: 'Reference / policy number'),
            LField(label: 'Renewal / expiry date'),
            LField(label: 'Notes'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Save record', onPressed: () => Navigator.pushReplacementNamed(context, '/record-detail')),
          const SizedBox(height: 8),
          GhostButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }
}

class ReviewExtractionScreen extends StatelessWidget {
  const ReviewExtractionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Review details', subtitle: 'Confirm extracted information', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            LField(label: 'Title', initialValue: 'AXA Home Insurance'),
            LField(label: 'Category', initialValue: 'Insurance'),
            LField(label: 'Provider', initialValue: 'AXA UK'),
            LField(label: 'Policy number', initialValue: 'AXA-882140-UK'),
            LField(label: 'Renewal date', initialValue: '22 May 2026'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Confirm and save', onPressed: () => Navigator.pushReplacementNamed(context, '/record-detail')),
          const SizedBox(height: 8),
          GhostButton(label: 'Edit details', onPressed: () {}),
        ]),
      ),
    );
  }
}

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(
        title: 'AXA Home Insurance',
        subtitle: 'Insurance · Active',
        onBack: () => Navigator.pop(context),
        trailing: const HeaderIcon(icon: Icons.more_horiz_rounded),
      ),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            StatusBadge(kind: BadgeKind.expiring, label: 'Expiring 22 May'),
            SizedBox(width: 8),
            StatusBadge(kind: BadgeKind.info, label: 'Renewal'),
          ]),
          const SizedBox(height: 14),
          LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _kv('Provider', 'AXA UK'),
            _kv('Policy number', 'AXA-882140-UK'),
            _kv('Cover', 'Buildings + Contents'),
            _kv('Renewal date', '22 May 2026'),
            _kv('Premium', '£42.18/month'),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('Documents'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.description_outlined, title: 'Policy schedule.pdf', subtitle: 'Uploaded 18 Apr'),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.image_outlined, title: 'Cover summary.jpg', subtitle: 'Uploaded 18 Apr'),
          ])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Edit', onPressed: () => Navigator.pushNamed(context, '/edit-record'))),
            const SizedBox(width: 10),
            Expanded(child: GhostButton(label: 'Replace', onPressed: () => Navigator.pushNamed(context, '/replace-renew-record'))),
          ]),
          const SizedBox(height: 8),
          GhostButton(label: 'Version history', onPressed: () => Navigator.pushNamed(context, '/version-history')),
        ])),
      ]),
    );
  }
}

class _kv extends StatelessWidget {
  final String k; final String v;
  const _kv(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 120, child: Text(k, style: const TextStyle(color: AppColors.text2, fontSize: 12))),
      Expanded(child: Text(v, style: const TextStyle(color: AppColors.text, fontSize: 14))),
    ]),
  );
}

class EditRecordScreen extends StatelessWidget {
  const EditRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Edit record', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        LCard(child: Column(children: const [
          LField(label: 'Title', initialValue: 'AXA Home Insurance'),
          LField(label: 'Provider', initialValue: 'AXA UK'),
          LField(label: 'Policy number', initialValue: 'AXA-882140-UK'),
          LField(label: 'Renewal date', initialValue: '22 May 2026'),
          LField(label: 'Notes'),
        ])),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Save changes', onPressed: () => Navigator.pop(context)),
      ])),
    );
  }
}

class ReplaceRenewRecordScreen extends StatelessWidget {
  const ReplaceRenewRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Replace / renew', subtitle: 'Upload latest version', onBack: () => Navigator.pop(context)),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Previous version', style: TextStyle(color: AppColors.text2, fontSize: 12))),
          Text('Policy schedule – 18 Apr 2025', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
        ])),
        const SizedBox(height: 12),
        LCard(child: Column(children: [
          ListRow(icon: Icons.upload_file_outlined, title: 'Upload new document'),
          const Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.edit_note_outlined, title: 'Update details manually'),
        ])),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Continue', onPressed: () => Navigator.pop(context)),
      ])),
    );
  }
}

class VersionHistoryScreen extends StatelessWidget {
  const VersionHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Version history', onBack: () => Navigator.pop(context)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        LCard(child: Column(children: const [
          ListRow(icon: Icons.history, title: 'Current — 18 Apr 2026', subtitle: 'Renewal updated', badge: StatusBadge(kind: BadgeKind.success, label: 'Current')),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.history, title: 'Version 2 — 22 May 2025', subtitle: 'Premium adjusted'),
          Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.history, title: 'Version 1 — 22 May 2024', subtitle: 'Original policy'),
        ])),
      ]),
    );
  }
}

class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Review queue', subtitle: '4 items need confirmation', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: LCard(child: Column(children: [
          ListRow(icon: Icons.shield_outlined, title: 'AXA Home Insurance', subtitle: 'Confirm renewal date',
              badge: const StatusBadge(kind: BadgeKind.review, label: 'Review'),
              onTap: () => Navigator.pushNamed(context, '/review-extraction')),
          const Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy bill', subtitle: 'Confirm amount',
              badge: const StatusBadge(kind: BadgeKind.review, label: 'Review'),
              onTap: () => Navigator.pushNamed(context, '/review-extraction')),
          const Divider(height: 1, color: AppColors.divider),
          ListRow(icon: Icons.badge_outlined, title: 'British Passport', subtitle: 'Confirm expiry date',
              badge: const StatusBadge(kind: BadgeKind.review, label: 'Review'),
              onTap: () => Navigator.pushNamed(context, '/review-extraction')),
        ]))),
      ]),
    );
  }
}
