import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../shared/widgets/l_widgets.dart';

const _kVaultCategories = <({String label, IconData icon, String id})>[
  (label: 'Identity',    icon: Icons.badge_outlined,           id: 'identity_legal'),
  (label: 'Insurance',   icon: Icons.shield_outlined,          id: 'insurance_protection'),
  (label: 'Banking',     icon: Icons.account_balance_outlined, id: 'banking_credit_borrowing'),
  (label: 'Utilities',   icon: Icons.bolt_outlined,            id: 'bills_utilities_subscriptions'),
  (label: 'Vehicle',     icon: Icons.directions_car_outlined,  id: 'vehicles_transport'),
  (label: 'Home',        icon: Icons.home_outlined,            id: 'home_property'),
  (label: 'Work',        icon: Icons.work_outline,             id: 'work_income_tax'),
  (label: 'Subs',        icon: Icons.subscriptions_outlined,   id: 'bills_utilities_subscriptions'),
  (label: 'Health',      icon: Icons.favorite_border,          id: 'insurance_protection'),
  (label: 'Family',      icon: Icons.group_outlined,           id: 'identity_legal'),
];

class VaultExplorerScreen extends StatefulWidget {
  const VaultExplorerScreen({super.key});

  @override
  State<VaultExplorerScreen> createState() => _VaultExplorerScreenState();
}

class _VaultExplorerScreenState extends State<VaultExplorerScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return LScreen(
      title: 'Vault',
      subtitle: 'Your secure records, on this device',
      searchHint: 'Search vault…',
      onSearchTap: () => context.go(AppRouter.search),
      trailing: HeaderIcon(
        icon: Icons.tune_rounded,
        onTap: () => context.go(AppRouter.search),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // ── Filter chips ───────────────────────────────────────────────
          FilterChipRow(
            chips: const ['All', 'Active', 'Expiring', 'Review', 'Drafts'],
            active: _filter,
            onChange: (c) => setState(() => _filter = c),
          ),
          const SizedBox(height: 20),

          // ── Categories ─────────────────────────────────────────────────
          const SectionTitle('Categories'),
          CategoryCarousel(
            items: _kVaultCategories,
            onTap: (id) => context.go('/vault/category/$id'),
          ),
          const SizedBox(height: 20),

          // ── Documents ─────────────────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: SectionTitle('Documents'),
              ),
              TextButton(
                onPressed: () => context.go(AppRouter.documents),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.royalPurple,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          LCard(
            padding: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 4),
            child: Column(
              children: [
                ListRow(
                  icon: Icons.badge_outlined,
                  title: 'Passports',
                  subtitle: 'Track expiry and renewal reminders',
                  onTap: () => context.go(AppRouter.passportList),
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.directions_car_outlined,
                  title: 'Driving licences',
                  subtitle: 'Photocard expiry and categories',
                  onTap: () =>
                      context.go(AppRouter.drivingLicenceList),
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.description_outlined,
                  title: 'All documents',
                  subtitle: 'Browse all saved documents',
                  onTap: () => context.go(AppRouter.documents),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Bills & subscriptions ──────────────────────────────────────
          const SectionTitle('Bills & Subscriptions'),
          LCard(
            padding: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 4),
            child: Column(
              children: [
                ListRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Bills',
                  subtitle: 'Recurring payments and due dates',
                  onTap: () => context.go(AppRouter.bills),
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListRow(
                  icon: Icons.shield_outlined,
                  title: 'Insurance policies',
                  subtitle: 'Renewal dates and coverage details',
                  onTap: () => context.go(AppRouter.policies),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Privacy note ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paleLavender,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline,
                    color: AppColors.royalPurple, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your device is the system of record. Nothing leaves this app without your permission.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
