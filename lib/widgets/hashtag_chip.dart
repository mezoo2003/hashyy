import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/hashtag.dart';

class HashtagChip extends StatelessWidget {
  final Hashtag hashtag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool dense;

  const HashtagChip({
    super.key,
    required this.hashtag,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(hashtag.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 14, vertical: dense ? 6 : 9),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : color.withOpacity(0.35), width: selected ? 1.6 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 0, right: 6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (hashtag.isLocked)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.lock, size: dense ? 11 : 13, color: color),
              ),
            if (hashtag.isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.push_pin, size: dense ? 11 : 13, color: color),
              ),
            Text(
              '#${hashtag.name}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: dense ? 12.5 : 14,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close, size: dense ? 14 : 16, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
