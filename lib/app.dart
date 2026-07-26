import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/gallery_provider.dart';
import 'providers/hashtag_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_shell.dart';

class HashGalleryApp extends StatelessWidget {
  const HashGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load(deviceLocale)),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => HashtagProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.loaded) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            title: 'Hash Gallery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
