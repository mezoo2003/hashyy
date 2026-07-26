import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../core/theme/app_colors.dart';

class PhotoThumb extends StatelessWidget {
  final AssetEntity asset;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PhotoThumb({
    super.key,
    required this.asset,
    this.selectionMode = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = asset.type == AssetType.video;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.border.withOpacity(0.4),
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(300),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isVideo)
            Positioned(
              left: 6,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(asset.videoDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          if (selectionMode)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.black.withOpacity(0.35),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
          if (selected)
            Container(color: AppColors.primary.withOpacity(0.30)),
        ],
      ),
    );
  }
}
