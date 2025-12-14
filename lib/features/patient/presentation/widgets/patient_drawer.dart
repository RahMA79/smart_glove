import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDrawer extends StatelessWidget {
  final String patientName;
  const PatientDrawer({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/person.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    patientName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          drawerItem(Icons.home_outlined, "Home", () {
            Navigator.pop(context);
          }),

          drawerItem(Icons.person_outline, "Profile", () {}),

          drawerItem(Icons.bar_chart, "Progress", () {}),

          // Notifications with red badge
          ListTile(
            leading: const Icon(Icons.notifications_outlined, size: 26),
            title: Row(
              children: [
                const Text("Notifications"),
                const SizedBox(width: 6),

                // Badge
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {},
          ),

          drawerItem(Icons.history, "Session History", () {}),

          drawerItem(Icons.settings_outlined, "Settings", () {}),

          const Spacer(),

          drawerItem(Icons.logout, "Logout", () {}),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ===== Helper function for simple drawer items =====
  Widget drawerItem(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
