import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/hashtag_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/add_hashtag_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/photo_thumb.dart';
import '../../widgets/selection_toolbar.dart';
import '../photo_detail/photo_detail_screen.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  Map<String, List<int>> _assetTagMap = {};
  String? _tagMapForStatus;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  Future<void> _loadTagMap(List<AssetEntity> assets) async {
    final provider = context.read<HashtagProvider>();
    final ids = assets.map((a) => a.id).toList();
    final map = await provider.hashtagIdsForAssets(ids);
    if (mounted) setState(() => _assetTagMap = map);
  }

  bool _isHiddenByLock(AssetEntity asset, HashtagProvider hp) {
    final tagIds = _assetTagMap[asset.id];
    if (tagIds == null || tagIds.isEmpty) return false;
    for (final id in tagIds) {
      final matches = hp.hashtags.where((x) => x.id == id);
      if (matches.isNotEmpty && matches.first.isLocked && !hp.unlockedIds.contains(id)) {
        return true;
      }
    }
    return false;
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<GalleryProvider, HashtagProvider, SettingsProvider>(
      builder: (context, gallery, hashtagP, settings, _) {
        Widget body;

        if (gallery.status == GalleryStatus.initial || gallery.status == GalleryStatus.loading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (gallery.status == GalleryStatus.denied) {
          body = EmptyState(
            icon: Icons.photo_library_outlined,
            title: context.tr('permissionRequired'),
            subtitle: context.tr('permissionRequiredDesc'),
            action: Column(
              children: [
                ElevatedButton(onPressed: gallery.init, child: Text(context.tr('grantAccess'))),
                TextButton(
                  onPressed: gallery.openAppSettings,
                  child: Text(context.tr('openSettings')),
                ),
              ],
            ),
          );
        } else if (gallery.status == GalleryStatus.error) {
          body = EmptyState(
            icon: Icons.error_outline,
            title: context.tr('somethingWentWrong'),
            action: ElevatedButton(onPressed: gallery.init, child: Text(context.tr('retry'))),
          );
        } else if (gallery.assets.isEmpty) {
          body = EmptyState(
            icon: Icons.photo_library_outlined,
            title: context.tr('noPhotos'),
            subtitle: context.tr('noPhotosDesc'),
          );
        } else {
          final statusKey = '${gallery.assets.length}';
          if (_tagMapForStatus != statusKey) {
            _tagMapForStatus = statusKey;
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadTagMap(gallery.assets));
          }

          final visible = gallery.assets.where((a) => !_isHiddenByLock(a, hashtagP)).toList()
            ..sort((a, b) => settings.sortNewestFirst
                ? b.createDateTime.compareTo(a.createDateTime)
                : a.createDateTime.compareTo(b.createDateTime));

          body = RefreshIndicator(
            onRefresh: gallery.refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final asset = visible[i];
                final selected = _selectedIds.contains(asset.id);
                return PhotoThumb(
                  asset: asset,
                  selectionMode: _selectionMode,
                  selected: selected,
                  onTap: () {
                    if (_selectionMode) {
                      _toggleSelect(asset.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotoDetailScreen(assets: visible, initialIndex: i),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    if (_selectionMode) return;
                    showAddHashtagSheet(context, assetIds: [asset.id]);
                  },
                );
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('gallery')),
            actions: [
              if (gallery.status == GalleryStatus.ready &&
                  gallery.assets.isNotEmpty &&
                  !_selectionMode)
                IconButton(
                  tooltip: settings.sortNewestFirst
                      ? context.tr('sortOldestFirst')
                      : context.tr('sortNewestFirst'),
                  icon: Icon(
                    settings.sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                  ),
                  onPressed: settings.toggleSortOrder,
                ),
              if (gallery.status == GalleryStatus.ready && gallery.assets.isNotEmpty)
                IconButton(
                  tooltip: context.tr('selectAll'),
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
          body: Column(
            children: [
              if (_selectionMode)
                Container(
                  width: double.infinity,
                  color: AppColors.primary.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    context.tr('bulkSelectHint'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primary, fontSize: 12.5),
                  ),
                ),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: _selectionMode
              ? SelectionToolbar(
                  selectedCount: _selectedIds.length,
                  onSelectAll: () => setState(
                    () => _selectedIds.addAll(gallery.assets.map((a) => a.id)),
                  ),
                  onAddHashtag: () async {
                    await showAddHashtagSheet(
                      context,
                      assetIds: _selectedIds.toList(),
                      bulk: true,
                    );
                    _exitSelection();
                  },
                  onCancel: _exitSelection,
                )
              : null,
        );
      },
    );
  }
}            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final asset = visible[i];
                final selected = _selectedIds.contains(asset.id);
                return PhotoThumb(
                  asset: asset,
                  selectionMode: _selectionMode,
                  selected: selected,
                  onTap: () {
                    if (_selectionMode) {
                      _toggleSelect(asset.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotoDetailScreen(assets: visible, initialIndex: i),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    if (_selectionMode) return;
                    showAddHashtagSheet(context, assetIds: [asset.id]);
                  },
                );
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('gallery')),
            actions: [
              if (gallery.status == GalleryStatus.ready && gallery.assets.isNotEmpty)
                IconButton(
                  tooltip: context.tr('selectAll'),
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
          body: Column(
            children: [
              if (_selectionMode)
                Container(
                  width: double.infinity,
                  color: AppColors.primary.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    context.tr('bulkSelectHint'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primary, fontSize: 12.5),
                  ),
                ),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: _selectionMode
              ? SelectionToolbar(
                  selectedCount: _selectedIds.length,
                  onSelectAll: () => setState(
                    () => _selectedIds.addAll(gallery.assets.map((a) => a.id)),
                  ),
                  onAddHashtag: () async {
                    await showAddHashtagSheet(
                      context,
                      assetIds: _selectedIds.toList(),
                      bulk: true,
                    );
                    _exitSelection();
                  },
                  onCancel: _exitSelection,
                )
              : null,
        );
      },
    );
  }
}
