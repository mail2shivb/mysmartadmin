import 'package:flutter/material.dart';
import '../../core/taxonomy/domain.dart';
import '../../core/utils/constants.dart';

/// Categories screen
/// 
/// Displays the 8 hard-coded domains:
/// 1. Identity & Legal Documents (MVP priority)
/// 2. Vehicles & Transport
/// 3. Property & Home
/// 4. Insurance & Protection
/// 5. Banking & Credit
/// 6. Subscriptions & Memberships
/// 7. Employment & Income
/// 8. General Documents
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final domains = Domain.values.toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: domains.length,
        itemBuilder: (context, index) {
          final domain = domains[index];
          return _DomainCard(domain: domain);
        },
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final Domain domain;

  const _DomainCard({required this.domain});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(domain.icon),
        ),
        title: Text(domain.displayName),
        subtitle: domain.priority == 1
            ? const Text('MVP Priority', style: TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to domain detail screen
        },
      ),
    );
  }
}
