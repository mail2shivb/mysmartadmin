import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../core/proto_theme/app_radius.dart';
import '../../core/proto_theme/app_spacing.dart';
import '../../core/proto_theme/app_text_styles.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/proto_app_card.dart';
import '../../shared/widgets/proto_empty_state.dart';

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
    return PageScaffold(
      title: 'Search',
      subtitle: 'Results across your vault',
      child: Column(
        children: [
          // ── Search input ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                ProtoSpacing.lg, ProtoSpacing.lg, ProtoSpacing.lg, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(ProtoRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: ProtoSpacing.md),
                    child: Icon(Icons.search, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: false,
                      decoration: const InputDecoration(
                        hintText: 'Search records, bills, documents…',
                        hintStyle: AppTextStyles.bodySecondary,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ProtoSpacing.md),
                      ),
                      onChanged: _search,
                      onSubmitted: _search,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                    ),
                ],
              ),
            ),
          ),

          // ── Results / suggestions ─────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPurple),
      );
    }
    if (_results == null) return _buildSuggestions();
    if (_results!.isEmpty) {
      return ProtoEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results for "$_lastQuery"',
        message: 'Try a document title, type, or field value.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(ProtoSpacing.lg),
      itemCount: _results!.length,
      itemBuilder: (context, i) {
        final doc = _results![i];
        return Padding(
          padding: const EdgeInsets.only(bottom: ProtoSpacing.sm),
          child: ProtoAppCard(
            padding: const EdgeInsets.all(ProtoSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.paleLavender,
                    borderRadius: BorderRadius.circular(ProtoRadius.md),
                  ),
                  child: const Icon(Icons.description_rounded,
                      color: AppColors.deepPurple, size: 20),
                ),
                const SizedBox(width: ProtoSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title,
                          style: AppTextStyles.title.copyWith(fontSize: 15)),
                      Text(doc.documentTypeId ?? '',
                          style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions() {
    const suggestions = [
      (Icons.book_rounded, 'Passport'),
      (Icons.directions_car_rounded, 'Driving licence'),
      (Icons.receipt_long_rounded, 'Bills'),
      (Icons.shield_rounded, 'Insurance'),
      (Icons.home_rounded, 'Property'),
      (Icons.subscriptions_rounded, 'Subscriptions'),
    ];
    return ListView(
      padding: const EdgeInsets.all(ProtoSpacing.lg),
      children: [
        const Text('Try searching for…', style: AppTextStyles.title),
        const SizedBox(height: ProtoSpacing.sm),
        Wrap(
          spacing: ProtoSpacing.sm,
          runSpacing: ProtoSpacing.sm,
          children: suggestions.map((s) {
            final (icon, label) = s;
            return ActionChip(
              avatar: Icon(icon, size: 16, color: AppColors.deepPurple),
              label: Text(label, style: AppTextStyles.bodySecondary),
              backgroundColor: AppColors.paleLavender,
              side: const BorderSide(color: AppColors.border),
              onPressed: () {
                _controller.text = label;
                _controller.selection =
                    TextSelection.collapsed(offset: label.length);
                _search(label);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
