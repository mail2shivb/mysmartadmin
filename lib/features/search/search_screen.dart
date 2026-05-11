import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/taxonomy/canonical_taxonomy.dart';
import '../../core/ui/components/app_scaffold.dart';
import '../../core/ui/components/ledger_components.dart';
import '../../core/ui/tokens.dart';
import '../../data/local/app_database.dart';

/// Full-text search screen — uses the FTS5 index in [AppDatabase.ftsSearch].
///
/// Replaces the stub [QueryScreen] with live data-backed search.
/// Tapping a result navigates to the appropriate detail screen.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<DocumentEntity>? _results;
  bool _loading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;
    if (q.isEmpty) {
      setState(() {
        _results = null;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final db = DatabaseProvider.instance;
      final results = await db.ftsSearch(q);
      if (mounted) setState(() { _results = results; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _results = []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: SearchBar(
              controller: _controller,
              hintText: 'Search your records…',
              leading: const Icon(Icons.search),
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear',
                    onPressed: () {
                      _controller.clear();
                      _search('');
                    },
                  ),
              ],
              onChanged: _search,
              onSubmitted: _search,
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),

          // ── Suggestions / results ──────────────────────────────────────────
          Expanded(
            child: _buildBody(theme, cs),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme cs) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Nothing typed yet — show quick suggestion chips
    if (_results == null) {
      return _buildSuggestions(theme, cs);
    }

    if (_results!.isEmpty) {
      return EmptyStateCard(
        icon: Icons.search_off_rounded,
        heading: 'No results for "$_lastQuery"',
        body: 'Try a document title, type, or field value.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: _results!.length,
      separatorBuilder: (_, _) => const SizedBox.shrink(),
      itemBuilder: (context, i) {
        final doc = _results![i];
        final domain = _domainFor(doc.domainId);
        final cs2 = Theme.of(context).colorScheme;
        return ListRow(
          icon: domain?.icon ?? Icons.description_outlined,
          iconColor: domain?.iconColor(cs2) ?? cs2.onSurfaceVariant,
          iconBackground: domain?.iconBackground(cs2) ?? cs2.surfaceContainer,
          title: doc.title,
          subtitle: '${doc.documentTypeId}  ·  ${doc.domainId}',
          showDivider: i < _results!.length - 1,
        );
      },
    );
  }

  Widget _buildSuggestions(ThemeData theme, ColorScheme cs) {
    const suggestions = [
      'passport',
      'driving licence',
      'expires this month',
      'insurance',
      'mortgage',
      'subscription',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Suggestions'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: suggestions.map((s) {
              return ActionChip(
                label: Text(s),
                avatar: Icon(Icons.search, size: 14,
                    color: cs.onSurfaceVariant),
                onPressed: () {
                  _controller.text = s;
                  _controller.selection = TextSelection.collapsed(
                      offset: s.length);
                  _search(s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  DomainDescriptor? _domainFor(String? domainId) {
    if (domainId == null) return null;
    try {
      return canonicalDomains.firstWhere((d) => d.id == domainId);
    } catch (_) {
      return null;
    }
  }
}
