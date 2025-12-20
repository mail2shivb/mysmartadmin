import 'package:flutter/material.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/components/insight_card.dart';

/// Query/Search screen
/// 
/// Features:
/// - Text input for queries
/// - Voice input (on-device speech-to-text, future)
/// - Example queries
/// - Deterministic query execution
/// 
/// Examples:
/// - "When does my passport expire?"
/// - "List all active insurance policies"
/// - "Show my credit cards and limits"
class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Search & Query'),
      ),
      enableScroll: true,
      padding: AppPadding.screen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          SearchBar(
            controller: _searchController,
            hintText: 'Ask about your documents...',
            leading: const Icon(Icons.search),
            trailing: [
              IconButton(
                icon: const Icon(Icons.mic_none),
                onPressed: () {
                  // TODO: Voice input (on-device speech-to-text)
                },
                tooltip: 'Voice search',
              ),
            ],
            onSubmitted: (query) {
              // TODO: Execute query
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Example queries section
          const SectionHeader(title: 'Example Queries'),
          InsightCard(
            leadingIcon: Icons.lightbulb_outline,
            title: 'When does my passport expire?',
            subtitle: 'Check expiry dates',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              _searchController.text = 'When does my passport expire?';
            },
          ),
          InsightCard(
            leadingIcon: Icons.lightbulb_outline,
            title: 'List all active insurance policies',
            subtitle: 'View insurance documents',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              _searchController.text = 'List all active insurance policies';
            },
          ),
          InsightCard(
            leadingIcon: Icons.lightbulb_outline,
            title: 'Show my credit cards and limits',
            subtitle: 'View banking information',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              _searchController.text = 'Show my credit cards and limits';
            },
          ),
          InsightCard(
            leadingIcon: Icons.lightbulb_outline,
            title: 'What documents expire this month?',
            subtitle: 'Upcoming expiries',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              _searchController.text = 'What documents expire this month?';
            },
          ),
        ],
      ),
    );
  }
}
