import 'package:flutter/material.dart';
import 'package:smart_glove/core/theme/app_colors.dart';

class DoctorDrawer extends StatelessWidget {
  const DoctorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.background),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/doc.jpg'),
                ),
                SizedBox(width: 12),
                Text(
                  'Dr. Sarah Ahmed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, 'Home', () {
            Navigator.pop(context);
          }),
          _drawerItem(Icons.people, 'My Patients', () {
            // TO DO: navigation
          }),
          _drawerItem(Icons.person_add, 'New Patient Requests', () {}),
          _drawerItem(Icons.notifications, 'Notifications', () {}),
          _drawerItem(Icons.settings, 'Settings', () {}),
          const Spacer(),
          _drawerItem(Icons.logout, 'Logout', () {}),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      onTap: onTap,
    );
  }
}
