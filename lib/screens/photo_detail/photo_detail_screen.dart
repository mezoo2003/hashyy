import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/hashtag.dart';
import '../../l10n/app_strings.dart';
import '../../providers/hashtag_provider.dart';
import '../../widgets/add_hashtag_sheet.dart';
import '../../widgets/hashtag_chip.dart';

class PhotoDetailScreen extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const PhotoDetailScreen({super.key, required this.assets, required this.initialIndex});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.assets[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_currentIndex + 1} / ${widget.assets.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.assets.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) {
                  final a = widget.assets[i];
                  return a.type == AssetType.video ? _VideoView(asset: a) : _ImageView(asset: a);
                },
              ),
            ),
            _HashtagBar(asset: asset),
          ],
        ),
      ),
    );
  }
}

class _ImageView extends StatelessWidget {
  final AssetEntity asset;
  const _ImageView({required this.asset});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: Center(
        child: AssetEntityImage(
          asset,
          isOriginal: true,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _VideoView extends StatefulWidget {
  final AssetEntity asset;
  const _VideoView({required this.asset});

  @override
  State<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final file = await widget.asset.file;
    if (file == null || !mounted) return;
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    controller.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        });
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              if (!controller.value.isPlaying)
                Container(
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 42),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HashtagBar extends StatefulWidget {
  final AssetEntity asset;
  const _HashtagBar({required this.asset});

  @override
  State<_HashtagBar> createState() => _HashtagBarState();
}

class _HashtagBarState extends State<_HashtagBar> {
  List<Hashtag> _tags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _HashtagBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tags = await context.read<HashtagProvider>().hashtagsForAsset(widget.asset.id);
    if (mounted) {
      setState(() {
        _tags = tags;
        _loading = false;
      });
    }
  }

  Future<void> _openSheet() async {
    await showAddHashtagSheet(context, assetIds: [widget.asset.id]);
    _load();
  }

  Future<void> _remove(Hashtag h) async {
    await context.read<HashtagProvider>().untagAsset(widget.asset.id, h.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loading)
            const SizedBox(
              height: 30,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                ),
              ),
            )
          else if (_tags.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(context.tr('noHashtagSelected'), style: const TextStyle(color: Colors.white70)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((h) => HashtagChip(hashtag: h, dense: true, onDeleted: () => _remove(h))).toList(),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
              onPressed: _openSheet,
              icon: const Icon(Icons.add),
              label: Text(context.tr('addHashtag')),
            ),
          ),
        ],
      ),
    );
  }
}
