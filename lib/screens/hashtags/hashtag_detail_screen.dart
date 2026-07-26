import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/hashtag.dart';
import '../../l10n/app_strings.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/hashtag_provider.dart';
import '../../widgets/add_hashtag_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/photo_thumb.dart';
import '../../widgets/selection_toolbar.dart';
import '../photo_detail/photo_detail_screen.dart';
import '../unlock/unlock_screen.dart';

class HashtagDetailScreen extends StatefulWidget {
  final Hashtag hashtag;
  const HashtagDetailScreen({super.key, required this.hashtag});

  @override
  State<HashtagDetailScreen> createState() => _HashtagDetailScreenState();
}

class _HashtagDetailScreenState extends State<HashtagDetailScreen> {
  late Hashtag _hashtag;
  List<AssetEntity> _assets = [];
  bool _loading = true;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _hashtag = widget.hashtag;
    _ensureUnlockedThenLoad();
  }

  Future<void> _ensureUnlockedThenLoad() async {
    final hp = context.read<HashtagProvider>();
    if (_hashtag.isLocked && !hp.isUnlocked(_hashtag)) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => UnlockScreen(hashtag: _hashtag)),
      );
      if (ok != true) {
        if (mounted) Navigator.pop(context);
        return;
      }
    }
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final hp = context.read<HashtagProvider>();
    final gallery = context.read<GalleryProvider>();
    final ids = await hp.assetIdsForHashtag(_hashtag);
    final assets = ids.map(gallery.byId).whereType<AssetEntity>().toList();
    if (mounted) {
      setState(() {
        _assets = assets;
        _loading = false;
      });
    }
  }

  void _exitSelection() => setState(() {
        _selectionMode = false;
        _selectedIds.clear();
      });

  Future<void> _changeSort(String sort) async {
    final hp = context.read<HashtagProvider>();
    await hp.setSortPreference(_hashtag, sort);
    setState(() => _hashtag = _hashtag.copyWith(sortPreference: sort));
    _load();
  }

  Future<void> _removeSelectedFromHashtag() async {
    final hp = context.read<HashtagProvider>();
    for (final id in _selectedIds) {
      await hp.untagAsset(id, _hashtag.id!);
    }
    _exitSelection();
    _load();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _assets.removeAt(oldIndex);
      _assets.insert(newIndex, item);
    });
    await context.read<HashtagProvider>().reorder(_hashtag, _assets.map((a) => a.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(_hashtag.colorHex);
    final isManual = _hashtag.sortPreference == 'manual';

    return Scaffold(
      appBar: AppBar(
        title: Text('#${_hashtag.name}'),
        iconTheme: IconThemeData(color: color),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: context.tr('sortBy'),
            onSelected: _changeSort,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'newest', child: Text(context.tr('newest'))),
              PopupMenuItem(value: 'oldest', child: Text(context.tr('oldest'))),
              PopupMenuItem(value: 'manual', child: Text(context.tr('manualOrder'))),
            ],
          ),
          if (!isManual && _assets.isNotEmpty)
            IconButton(
              icon: Icon(_selectionMode ? Icons.close : Icons.checklist_rounded),
              onPressed: () {
                if (_selectionMode) {
                  _exitSelection();
                } else {
                  setState(() => _selectionMode = true);
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _assets.isEmpty
              ? EmptyState(icon: Icons.photo_outlined, title: context.tr('noPhotos'))
              : isManual
                  ? _buildManualList()
                  : _buildGrid(),
      bottomNavigationBar: (_selectionMode && !isManual)
          ? SelectionToolbar(
              selectedCount: _selectedIds.length,
              removeLabel: context.tr('removeHashtag'),
              onSelectAll: () => setState(() => _selectedIds.addAll(_assets.map((a) => a.id))),
              onRemove: _removeSelectedFromHashtag,
              onAddHashtag: () async {
                await showAddHashtagSheet(context, assetIds: _selectedIds.toList(), bulk: true);
                _exitSelection();
              },
              onCancel: _exitSelection,
            )
          : null,
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, i) {
        final asset = _assets[i];
        final selected = _selectedIds.contains(asset.id);
        return PhotoThumb(
          asset: asset,
          selectionMode: _selectionMode,
          selected: selected,
          onTap: () {
            if (_selectionMode) {
              setState(() {
                if (selected) {
                  _selectedIds.remove(asset.id);
                } else {
                  _selectedIds.add(asset.id);
                }
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoDetailScreen(assets: _assets, initialIndex: i)),
              );
            }
          },
          onLongPress: () {
            if (_selectionMode) return;
            showAddHashtagSheet(context, assetIds: [asset.id]).then((_) => _load());
          },
        );
      },
    );
  }

  Widget _buildManualList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _assets.length,
      onReorder: _reorder,
      itemBuilder: (context, i) {
        final asset = _assets[i];
        return ListTile(
          key: ValueKey(asset.id),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(120),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(asset.type == AssetType.video ? context.tr('video') : ''),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PhotoDetailScreen(assets: _assets, initialIndex: i)),
          ),
          trailing: const Icon(Icons.drag_handle),
        );
      },
    );
  }
}
