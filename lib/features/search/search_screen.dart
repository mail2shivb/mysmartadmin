import 'package:flutter/material.dart';

import '../../core/database_provider.dart';
import '../../core/proto_theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../shared/widgets/l_widgets.dart';

/// Search screen — full-text search across the vault.
/// Uses LScreen so it renders as a push route with gradient header + back button.
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
    return LScreen(
      title: 'Search',
      subtitle: 'Records, reminders, tasks…',
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        children: [
          // ── Active search bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.paleLavender,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type to search…',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: _search,
                      onSubmitted: _search,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                    ),
                ],
              ),
            ),
          ),

          // ── Results / suggestions ─────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
              color: AppColors.primaryPurple, strokeWidth: 2),
        ),
      );
    }
    if (_results == null) return _buildSuggestions();
    if (_results!.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          LEmptyState(
            icon: Icons.search_off_rounded,
            title: 'No results for "$_lastQuery"',
            message: 'Try a document title, type, or field value.',
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: _results!.length,
      separatorBuilder: (context2, i2) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final doc = _results![i];
        return LCard(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: ListRow(
            icon: Icons.description_outlined,
            title: doc.title,
            subtitle: doc.documentTypeId,
          ),
        );
      },
    );
  }

  Widget _buildSuggestions() {
    const chips = [
      (Icons.book_rounded, 'Passport'),
      (Icons.directions_car_rounded, 'Driving licence'),
      (Icons.receipt_long_rounded, 'Bills'),
      (Icons.shield_rounded, 'Insurance'),
      (Icons.home_rounded, 'Property'),
      (Icons.subscriptions_rounded, 'Subscriptions'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        const SectionTitle('Try searching for…'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((s) {
            final (icon, label) = s;
            return ActionChip(
              avatar: Icon(icon, size: 16, color: AppColors.royalPurple),
              label: Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13)),
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
