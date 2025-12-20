import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Query'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SearchBar(
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
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                Text(
                  'Example Queries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildExampleQuery(
                  context,
                  'When does my passport expire?',
                ),
                _buildExampleQuery(
                  context,
                  'List all active insurance policies',
                ),
                _buildExampleQuery(
                  context,
                  'Show my credit cards and limits',
                ),
                _buildExampleQuery(
                  context,
                  'What documents expire this month?',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleQuery(BuildContext context, String query) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline),
        title: Text(query),
        onTap: () {
          _searchController.text = query;
          // TODO: Execute example query
        },
      ),
    );
  }
}
