// F2.1 STATUS: RE-IMPLEMENTED

import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// Bottom sheet for choosing how to add new data
/// 
/// Presents two options:
/// - Add Document (scan or upload)
/// - Manual Entry (bills, subscriptions, policies)
class AddEntryBottomSheet extends StatelessWidget {
  const AddEntryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: Spacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Text(
                'Add to Ledger',
                style: theme.textTheme.titleLarge,
              ),
            ),
            
            // Options
            ListTile(
              leading: Icon(
                Icons.document_scanner_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Add Document',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Scan or upload a document',
                style: theme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDocumentScreen(),
                  ),
                );
              },
            ),
            
            const Divider(height: 1),
            
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Manual Entry',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Add bill, subscription, or policy',
                style: theme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualEntryScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for Add Document flow
class AddDocumentScreen extends StatelessWidget {
  const AddDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Document'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxl * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: Spacing.xl),
                    Text(
                      'Document Scanning',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Coming next in F2.x',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for Manual Entry flow
class ManualEntryScreen extends StatelessWidget {
  const ManualEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manual Entry'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxl * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: Spacing.xl),
                    Text(
                      'Manual Data Entry',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Coming next in F2.x',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

