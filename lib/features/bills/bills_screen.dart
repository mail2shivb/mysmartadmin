import 'package:flutter/material.dart';

/// Bills management screen (temporarily disabled)
class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Bills UI disabled temporarily'),
      ),
    );
  }
}

/*
// ORIGINAL CODE COMMENTED OUT FOR STABILIZATION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/database_provider.dart';
import '../../domain/usecases/commitments/create_bill_usecase.dart';
import '../../domain/usecases/commitments/get_active_bills_usecase.dart';
import '../../data/local/tables/bills.dart';

/// Bills management screen
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _database = DatabaseProvider.instance;
  late final _getActiveBillsUseCase = GetActiveBillsUseCase(_database);
  late final _createBillUseCase = CreateBillUseCase(_database);

  List<BillEntity> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _loading = true);
    try {
      final bills = await _getActiveBillsUseCase();
      setState(() {
        _bills = bills;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bills: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _showAddBillDialog() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String? category = 'Utilities';
    String? frequency = 'monthly';
    bool isRecurring = true;
    DateTime? nextDueDate = DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (£) *',
                    prefixText: '£',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Utilities', child: Text('Utilities')),
                    DropdownMenuItem(value: 'Insurance', child: Text('Insurance')),
                    DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Recurring'),
                  value: isRecurring,
                  onChanged: (value) => setDialogState(() => isRecurring = value ?? true),
                ),
                if (isRecurring) ...[
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: const [
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                      DropdownMenuItem(value: 'annual', child: Text('Annual')),
                    ],
                    onChanged: (value) => setDialogState(() => frequency = value),
                  ),
                ],
                const SizedBox(height: 8),
                ListTile(
                  title: Text('Next Due: ${_formatDate(nextDueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: nextDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => nextDueDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final amountText = amountController.text.trim();
                
                if (name.isEmpty || amountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                try {
                  final amount = double.parse(amountText);
                  final amountCents = (amount * 100).round();

                  await _createBillUseCase(
                    name: name,
                    category: category ?? 'Other',
                    amountCents: amountCents,
                    isRecurring: isRecurring,
                    frequency: isRecurring ? frequency : null,
                    nextDueDate: nextDueDate,
                    generateReminder: true,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bill added! Reminder auto-created')),
                    );
                    _loadBills();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBills,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? const Center(child: Text('No bills yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text(bill.billName),
                        subtitle: Text(
                          '${bill.category} • ${bill.frequency ?? "One-time"}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '£${(bill.amountCents / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (bill.nextDueDate != null)
                              Text(
                                'Due: ${_formatDate(bill.nextDueDate)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBillDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/
