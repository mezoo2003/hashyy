import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../data/models/hashtag.dart';
import '../../l10n/app_strings.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/hashtag_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hashtag_chip.dart';
import '../../widgets/photo_thumb.dart';
import '../photo_detail/photo_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _controller = TextEditingController();
  final Set<int> _selectedHashtagIds = {};
  bool _matchAll = false;
  List<String> _resultAssetIds = [];
  bool _loading = false;

  List<Hashtag> _filteredSuggestions(List<Hashtag> all) {
    final query = _controller.text.trim().replaceAll('#', '').toLowerCase();
    if (query.isEmpty) return all;
    return all.where((h) => h.name.toLowerCase().contains(query)).toList();
  }

  Future<void> _runSearch() async {
    if (_selectedHashtagIds.isEmpty) {
      setState(() => _resultAssetIds = []);
      return;
    }
    setState(() => _loading = true);
    final hp = context.read<HashtagProvider>();
    final ids = await hp.search(_selectedHashtagIds.toList(), matchAll: _matchAll);
    final lockedIds = await hp.lockedAssetIds();
    final filtered = ids.where((id) => !lockedIds.contains(id)).toList();
    if (mounted) {
      setState(() {
        _resultAssetIds = filtered;
        _loading = false;
      });
    }
  }

  void _toggleHashtag(Hashtag h) {
    setState(() {
      if (_selectedHashtagIds.contains(h.id)) {
        _selectedHashtagIds.remove(h.id);
      } else {
        _selectedHashtagIds.add(h.id!);
      }
    });
    _runSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HashtagProvider>();
    final gallery = context.watch<GalleryProvider>();
    final suggestions = _filteredSuggestions(hp.hashtags);
    final resultAssets = _resultAssetIds.map(gallery.byId).whereType<AssetEntity>().toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('search'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: context.tr('searchHint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _controller.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_selectedHashtagIds.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(context.tr('advancedSearch'), style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  ChoiceChip(
                    label: Text(context.tr('matchAny')),
                    selected: !_matchAll,
                    onSelected: (_) {
                      setState(() => _matchAll = false);
                      _runSearch();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(context.tr('matchAll')),
                    selected: _matchAll,
                    onSelected: (_) {
                      setState(() => _matchAll = true);
                      _runSearch();
                    },
                  ),
                ],
              ),
            ),
          if (suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map(
                      (h) => HashtagChip(
                        hashtag: h,
                        dense: true,
                        selected: _selectedHashtagIds.contains(h.id),
                        onTap: () => _toggleHashtag(h),
                      ),
                    )
                    .toList(),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _selectedHashtagIds.isEmpty
                    ? EmptyState(icon: Icons.search_rounded, title: context.tr('selectHashtagsToSearch'))
                    : resultAssets.isEmpty
                        ? EmptyState(
                            icon: Icons.search_off_rounded,
                            title: context.tr('noResults'),
                            subtitle: context.tr('noResultsDesc'),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(2),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemCount: resultAssets.length,
                            itemBuilder: (context, i) {
                              final asset = resultAssets[i];
                              return PhotoThumb(
                                asset: asset,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PhotoDetailScreen(assets: resultAssets, initialIndex: i),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
