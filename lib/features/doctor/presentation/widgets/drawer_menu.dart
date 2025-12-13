import 'package:flutter/material.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';

class DoctorDrawer extends StatelessWidget {
  const DoctorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/doc.jpg'),
                ),
                const SizedBox(width: 12),
                Text(
                  'Dr. Sarah Ahmed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _drawerItem(context, Icons.home, 'Home', () {
            Navigator.pop(context);
          }),

          _drawerItem(context, Icons.people, 'My Patients', () {}),

          _drawerItem(context, Icons.person_add, 'New Patient Requests', () {}),

          _drawerItem(context, Icons.notifications, 'Notifications', () {}),

          _drawerItem(context, Icons.settings, 'Settings', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),

          const Spacer(),

          _drawerItem(context, Icons.logout, 'Logout', () {}),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: theme.textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}
