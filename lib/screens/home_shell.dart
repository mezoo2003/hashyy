import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../providers/gallery_provider.dart';
import '../providers/hashtag_provider.dart';
import 'gallery/gallery_tab.dart';
import 'hashtags/hashtags_tab.dart';
import 'search/search_tab.dart';
import 'settings/settings_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().init();
      context.read<HashtagProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      GalleryTab(),
      HashtagsTab(),
      SearchTab(),
      SettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: context.tr('gallery'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_offer_rounded),
            label: context.tr('hashtags'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_rounded),
            label: context.tr('search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_rounded),
            label: context.tr('settings'),
          ),
        ],
      ),
    );
  }
}
