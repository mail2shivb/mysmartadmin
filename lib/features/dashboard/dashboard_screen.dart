import 'package:flutter/material.dart';

/// Dashboard screen (temporarily disabled)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Dashboard UI disabled temporarily'),
      ),
    );
  }
}

/*
// ORIGINAL CODE COMMENTED OUT FOR STABILIZATION

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/usecases/commitments/calculate_monthly_commitments_usecase.dart';
import '../../domain/usecases/reminders/get_upcoming_reminders_usecase.dart';

/// Dashboard screen showing key metrics
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _database = DatabaseProvider.instance;
  late final _calculateCommitmentsUseCase = CalculateMonthlyCommitmentsUseCase(_database);
  late final _getUpcomingRemindersUseCase = GetUpcomingRemindersUseCase(_database);

  MonthlyCommitments? _commitments;
  int _pendingRemindersCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final commitments = await _calculateCommitmentsUseCase();
      final reminders = await _getUpcomingRemindersUseCase(lookaheadDays: 30);
      
      setState(() {
        _commitments = commitments;
        _pendingRemindersCount = reminders.length;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCommitmentsCard(),
                const SizedBox(height: 16),
                _buildRemindersCard(),
              ],
            ),
    );
  }

  Widget _buildCommitmentsCard() {
    final commitments = _commitments;
    if (commitments == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No commitments data'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Commitments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCommitmentRow('Bills', commitments.billsTotal),
            _buildCommitmentRow('Subscriptions', commitments.subscriptionsTotal),
            const Divider(height: 24),
            _buildCommitmentRow('Total', commitments.grandTotal, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentRow(String label, int amountCents, {bool bold = false}) {
    final amount = '£${(amountCents / 100).toStringAsFixed(2)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications),
        title: const Text('Pending Reminders'),
        trailing: Text(
          '$_pendingRemindersCount',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
*/
