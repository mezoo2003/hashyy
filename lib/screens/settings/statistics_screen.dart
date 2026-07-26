import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/hashtag_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _taggedCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hp = context.read<HashtagProvider>();
    final tagged = await hp.taggedPhotoCount();
    if (mounted) {
      setState(() {
        _taggedCount = tagged;
        _loading = false;
      });
    }
  }

  List<Widget> _buildBars(HashtagProvider hp) {
    final sorted = [...hp.hashtags]
      ..sort((a, b) => (hp.photoCounts[b.id] ?? 0).compareTo(hp.photoCounts[a.id] ?? 0));
    final maxCount = sorted.isEmpty ? 1 : (hp.photoCounts[sorted.first.id] ?? 1);
    final safeMax = maxCount == 0 ? 1 : maxCount;

    return sorted.map((h) {
      final count = hp.photoCounts[h.id] ?? 0;
      final color = AppColors.fromHex(h.colorHex);
      final ratio = count / safeMax;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('#${h.name}', overflow: TextOverflow.ellipsis)),
                Text('$count', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio.toDouble(),
                minHeight: 8,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HashtagProvider>();
    final gallery = context.watch<GalleryProvider>();
    final total = gallery.assets.length;
    final untagged = total - _taggedCount < 0 ? 0 : total - _taggedCount;
    final mostUsed = hp.mostUsed();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('statistics'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(label: context.tr('totalPhotos'), value: '$total', icon: Icons.photo_library_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: context.tr('taggedPhotos'),
                        value: '$_taggedCount',
                        icon: Icons.local_offer_outlined,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: context.tr('untaggedPhotos'),
                        value: '$untagged',
                        icon: Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StatCard(
                  label: context.tr('totalHashtags'),
                  value: '${hp.hashtags.length}',
                  icon: Icons.tag_rounded,
                ),
                if (mostUsed != null) ...[
                  const SizedBox(height: 22),
                  Text(context.tr('mostUsedHashtag'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.fromHex(mostUsed.colorHex).withOpacity(0.15),
                        child: Icon(Icons.tag, color: AppColors.fromHex(mostUsed.colorHex)),
                      ),
                      title: Text('#${mostUsed.name}'),
                      trailing: Text('${hp.photoCounts[mostUsed.id] ?? 0}'),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (hp.hashtags.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(context.tr('noDataYet'), style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else ...[
                  Text(context.tr('photosPerHashtag'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  ..._buildBars(hp),
                ],
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
