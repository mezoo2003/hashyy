import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kThemeKey = 'theme_mode';
  static const _kLangKey = 'language_code';
  static const _kSortNewestFirstKey = 'gallery_sort_newest_first';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _loaded = false;
  bool _sortNewestFirst = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get loaded => _loaded;

  /// When true, photos/videos are shown newest-first; when false, oldest-first.
  bool get sortNewestFirst => _sortNewestFirst;

  Future<void> load(Locale deviceLocale) async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_kThemeKey);
    _themeMode = switch (storedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final storedLang = prefs.getString(_kLangKey);
    if (storedLang == 'ar' || storedLang == 'en') {
      _locale = Locale(storedLang!);
    } else {
      _locale = deviceLocale.languageCode == 'ar' ? const Locale('ar') : const Locale('en');
    }

    _sortNewestFirst = prefs.getBool(_kSortNewestFirstKey) ?? true;

    _loaded = true;
    notifyListeners();
  }

  Future<void> setSortNewestFirst(bool value) async {
    _sortNewestFirst = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSortNewestFirstKey, value);
  }

  Future<void> toggleSortOrder() => setSortNewestFirst(!_sortNewestFirst);

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, locale.languageCode);
  }
}
