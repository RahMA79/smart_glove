import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme for the app'),
            value: themeNotifier.isDark,
            onChanged: (value) {
              themeNotifier.toggleTheme(value);
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Session reminders'),
            value: true,
            onChanged: (value) {
              // TODO: implement later
            },
          ),

          SwitchListTile(
            title: const Text('New patient requests'),
            value: true,
            onChanged: (value) {
              // TODO: implement later
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Account',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          ListTile(
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {
              // TODO: open language picker
            },
          ),

          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // TODO: handle logout
            },
          ),
        ],
      ),
    );
  }
}
