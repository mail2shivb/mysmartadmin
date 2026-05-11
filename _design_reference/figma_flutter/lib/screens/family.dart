import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shell.dart';

class FamilyAdminScreen extends StatelessWidget {
  const FamilyAdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Family', subtitle: 'Shared records and tasks', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Groups'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.group_outlined, title: 'Household', subtitle: '3 members · 12 shared items',
                onTap: () => Navigator.pushNamed(context, '/family-group-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.group_outlined, title: 'Parents', subtitle: '2 members · 4 shared items',
                onTap: () => Navigator.pushNamed(context, '/family-group-detail')),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('Recently shared'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy bill', subtitle: 'Shared with Sam',
                onTap: () => Navigator.pushNamed(context, '/shared-item-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.flight_outlined, title: 'Trip to Edinburgh', subtitle: 'Shared with Parents',
                onTap: () => Navigator.pushNamed(context, '/shared-item-detail')),
          ])),
        ])),
      ]),
    );
  }
}

class FamilyGroupDetailScreen extends StatelessWidget {
  const FamilyGroupDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Household', subtitle: '3 members', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Members'),
          LCard(child: Column(children: const [
            ListRow(icon: Icons.person_outline, title: 'Alex (you)', subtitle: 'Owner', badge: StatusBadge(kind: BadgeKind.active, label: 'Owner')),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.person_outline, title: 'Sam', subtitle: 'Editor'),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.person_outline, title: 'Jordan', subtitle: 'Viewer'),
          ])),
          const SizedBox(height: 12),
          const SectionTitle('Shared items'),
          LCard(child: Column(children: [
            ListRow(icon: Icons.bolt_outlined, title: 'Octopus Energy bill', onTap: () => Navigator.pushNamed(context, '/shared-item-detail')),
            const Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.shield_outlined, title: 'AXA Home Insurance', onTap: () => Navigator.pushNamed(context, '/shared-item-detail')),
          ])),
        ])),
      ]),
    );
  }
}

class AddSharedItemScreen extends StatelessWidget {
  const AddSharedItemScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBottomNav: false,
      header: SimpleHeader(title: 'Share an item', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        LCard(child: Column(children: const [
          LField(label: 'Type', hint: 'Bill / Trip / Task / Record'),
          LField(label: 'Title'),
          LField(label: 'Group', hint: 'Choose group'),
          LField(label: 'Permissions', hint: 'View / Edit'),
          LField(label: 'Notes'),
        ])),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Share item', onPressed: () => Navigator.pop(context)),
      ])),
    );
  }
}

class SharedItemDetailScreen extends StatelessWidget {
  const SharedItemDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: SlackStyleHeader(title: 'Octopus Energy bill', subtitle: 'Shared with Household', onBack: () => Navigator.pop(context)),
      body: ListView(padding: EdgeInsets.zero, children: [
        RoundedContentSheet(child: Column(children: [
          LCard(child: Column(children: const [
            ListRow(icon: Icons.person_outline, title: 'Alex', subtitle: 'Owner'),
            Divider(height: 1, color: AppColors.divider),
            ListRow(icon: Icons.person_outline, title: 'Sam', subtitle: 'Can edit'),
          ])),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Open record', onPressed: () => Navigator.pushNamed(context, '/record-detail')),
        ])),
      ]),
    );
  }
}
