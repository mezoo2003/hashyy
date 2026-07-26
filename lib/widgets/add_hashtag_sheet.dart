import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/hashtag.dart';
import '../l10n/app_strings.dart';
import '../providers/hashtag_provider.dart';
import 'create_hashtag_dialog.dart';
import 'empty_state.dart';

/// Opens the hashtag picker sheet.
///
/// - Single-photo mode (`assetIds.length == 1 && !bulk`): toggling a
///   hashtag tags/untags that photo immediately (matches the "long-press
///   quick tag" and "detail view" flows from the spec).
/// - Bulk mode (`bulk: true`): selections only get applied to every asset
///   in [assetIds] once the user taps Done.
Future<void> showAddHashtagSheet(
  BuildContext context, {
  required List<String> assetIds,
  bool bulk = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddHashtagSheet(assetIds: assetIds, bulk: bulk),
  );
}

class AddHashtagSheet extends StatefulWidget {
  final List<String> assetIds;
  final bool bulk;

  const AddHashtagSheet({super.key, required this.assetIds, required this.bulk});

  @override
  State<AddHashtagSheet> createState() => _AddHashtagSheetState();
}

class _AddHashtagSheetState extends State<AddHashtagSheet> {
  final Set<int> _selected = {};
  bool _loading = true;

  bool get _singleMode => !widget.bulk && widget.assetIds.length == 1;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (_singleMode) {
      final provider = context.read<HashtagProvider>();
      final existing = await provider.hashtagsForAsset(widget.assetIds.first);
      _selected.addAll(existing.map((h) => h.id!));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(Hashtag h) async {
    final provider = context.read<HashtagProvider>();
    final wasSelected = _selected.contains(h.id);
    setState(() {
      if (wasSelected) {
        _selected.remove(h.id);
      } else {
        _selected.add(h.id!);
      }
    });
    if (_singleMode) {
      if (wasSelected) {
        await provider.untagAsset(widget.assetIds.first, h.id!);
      } else {
        await provider.tagAsset(widget.assetIds.first, h.id!);
      }
    }
  }

  Future<void> _createNew() async {
    final created = await showCreateHashtagDialog(context);
    if (created != null && created.id != null && mounted) {
      setState(() => _selected.add(created.id!));
      if (_singleMode) {
        await context.read<HashtagProvider>().tagAsset(widget.assetIds.first, created.id!);
      }
    }
  }

  Future<void> _finish() async {
    if (widget.bulk && _selected.isNotEmpty) {
      await context.read<HashtagProvider>().tagAssets(widget.assetIds, _selected.toList());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hashtags = context.watch<HashtagProvider>().hashtags;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.bulk ? context.tr('addHashtags') : context.tr('addHashtagsToPhoto'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (widget.assetIds.length > 1)
                      Text(
                        '${widget.assetIds.length} ${context.tr('itemsLabel')}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : hashtags.isEmpty
                        ? EmptyState(
                            icon: Icons.local_offer_outlined,
                            title: context.tr('noHashtagsYet'),
                            subtitle: context.tr('noHashtagsYetDesc'),
                          )
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            children: hashtags.map((h) {
                              final isSelected = _selected.contains(h.id);
                              final color = AppColors.fromHex(h.colorHex);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => _toggle(h),
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: color,
                                title: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('#${h.name}'),
                                    if (h.isLocked) ...[
                                      const SizedBox(width: 6),
                                      Icon(Icons.lock, size: 13, color: color),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _createNew,
                        icon: const Icon(Icons.add),
                        label: Text(context.tr('newHashtag')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _finish,
                        child: Text(context.tr('done')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
