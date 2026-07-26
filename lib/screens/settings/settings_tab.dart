import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../providers/settings_provider.dart';
import '../hashtags/hashtags_tab.dart';
import 'statistics_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        children: [
          _SectionHeader(title: context.tr('language')),
          RadioListTile<String>(
            value: 'en',
            groupValue: settings.locale.languageCode,
            title: Text(context.tr('english')),
            activeColor: AppColors.primary,
            onChanged: (_) => settings.setLocale(const Locale('en')),
          ),
          RadioListTile<String>(
            value: 'ar',
            groupValue: settings.locale.languageCode,
            title: Text(context.tr('arabic')),
            activeColor: AppColors.primary,
            onChanged: (_) => settings.setLocale(const Locale('ar')),
          ),
          const Divider(),
          _SectionHeader(title: context.tr('theme')),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            title: Text(context.tr('systemMode')),
            activeColor: AppColors.primary,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            title: Text(context.tr('lightMode')),
            activeColor: AppColors.primary,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            title: Text(context.tr('darkMode')),
            activeColor: AppColors.primary,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          const Divider(),
          _SectionHeader(title: context.tr('manageHashtags')),
          ListTile(
            leading: const Icon(Icons.local_offer_outlined, color: AppColors.primary),
            title: Text(context.tr('manageHashtags')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HashtagsTab()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            title: Text(context.tr('statistics')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: Text(context.tr('about')),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(context.tr('appName')),
                content: Text(context.tr('aboutBody')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('close')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
