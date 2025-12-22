import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_notifications_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_progress_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';

class PatientDrawer extends StatefulWidget {
  final String patientName;

  /// ✅ نفس uid اللي بتبعيته للـ PatientHomeScreen
  final String userId;

  const PatientDrawer({
    super.key,
    required this.patientName,
    required this.userId,
  });

  @override
  State<PatientDrawer> createState() => _PatientDrawerState();
}

class _PatientDrawerState extends State<PatientDrawer> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path_${widget.userId}');
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      if (!mounted) return;
      setState(() => _profileImage = File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // ✅ Header ستايل أنضف + نفس صورة الهوم
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 46,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(isDark ? 0.16 : 0.10),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.18)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.person_rounded, color: cs.primary, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Patient",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          _drawerItem(
            context,
            icon: Icons.home_outlined,
            title: "Home",
            onTap: () => Navigator.pop(context),
          ),

          _drawerItem(
            context,
            icon: Icons.person_outline,
            title: "Profile",
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigator.pushNamed(context, '/profile');
            },
          ),

          _drawerItem(
            context,
            icon: Icons.bar_chart_rounded,
            title: "Progress",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PatientProgressScreen(
                      patientName: widget.patientName,
                    );
                  },
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications_outlined, size: 26),
            title: const Text("Notifications", style: TextStyle(fontSize: 16)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                "1",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorNotificationsScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            icon: Icons.history,
            title: "Session History",
            onTap: () {
              Navigator.pop(context);
              // TODO
            },
          ),

          _drawerItem(
            context,
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          const Spacer(),

          Divider(height: 1, color: theme.dividerColor.withOpacity(0.20)),

          _drawerItem(
            context,
            icon: Icons.logout_rounded,
            title: "Logout",
            danger: true,
            onTap: () async {
              await LogoutFunction.logout(context);
            },
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final color = danger ? cs.error : null;

    return ListTile(
      leading: Icon(icon, size: 26, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: danger ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
