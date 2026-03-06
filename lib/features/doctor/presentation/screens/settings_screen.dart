import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_notifier.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/localization/locale_notifier.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final langCode = localeNotifier.locale?.languageCode ?? 'en';

    Future<void> openLanguagePicker() async {
      final selected = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(ctx.tr('English')),
                  trailing: langCode == 'en'
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(ctx, 'en'),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(ctx.tr('Arabic')),
                  trailing: langCode == 'ar'
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(ctx, 'ar'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );

      if (selected == null) return;
      await localeNotifier.setLocale(Locale(selected));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
              );
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.tr('Appearance'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: Text(context.tr('Dark Mode')),
            subtitle: Text(context.tr('Enable dark theme for the app')),
            value: themeNotifier.isDark,
            onChanged: (value) {
              themeNotifier.toggleTheme(value);
            },
          ),

          const SizedBox(height: 24),

          Text(
            context.tr('Notifications'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: Text(context.tr('Session reminders')),
            value: true,
            onChanged: (value) {
              // TODO: implement later
            },
          ),

          SwitchListTile(
            title: Text(context.tr('New patient requests')),
            value: true,
            onChanged: (value) {
              // TODO: implement later
            },
          ),

          const SizedBox(height: 24),

          Text(
            context.tr('Account'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          ListTile(
            title: Text(context.tr('Language')),
            subtitle: Text(langCode == 'ar' ? context.tr('Arabic') : context.tr('English')),
            onTap: openLanguagePicker,
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.tr('Logout')),
            onTap: () => LogoutFunction.logout(context),
          ),
        ],
      ),
    );
  }
}
