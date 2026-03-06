import 'package:flutter/material.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_notifications_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/my_patients_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/new_patient_request_screen.dart';
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

          _drawerItem(context, Icons.home, context.tr('Home'), () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
            );
          }),

          _drawerItem(context, Icons.people, context.tr('My Patients'), () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPatientsScreen()),
            );
          }),

          _drawerItem(context, Icons.person_add, context.tr('New patient requests'), () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NewPatientRequestScreen(),
              ),
            );
          }),

          _drawerItem(context, Icons.notifications, context.tr('Notifications'), () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DoctorNotificationsScreen(),
              ),
            );
          }),

          _drawerItem(context, Icons.settings, context.tr('Settings'), () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),

          const Spacer(),

          _drawerItem(context, Icons.logout, context.tr('Logout'), () async {
            await LogoutFunction.logout(context);
          }),
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
