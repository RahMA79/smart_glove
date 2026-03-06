import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_progress_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_notifications_screen.dart'; // ⚠️ مؤقتًا لو مفيش PatientNotifications

class PatientDrawer extends StatefulWidget {
  final String patientName;
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

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.person_rounded, size: 30, color: cs.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _drawerItem(
            context,
            Icons.home_outlined,
            context.tr('drawer_home'),
            () {
              Navigator.pop(context);
            },
          ),

          _drawerItem(
            context,
            Icons.person_outline,
            context.tr('drawer_profile'),
            () {
              Navigator.pop(context);
            },
          ),

          _drawerItem(
            context,
            Icons.bar_chart_rounded,
            context.tr('drawer_progress'),
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PatientProgressScreen(patientName: widget.patientName),
                ),
              );
            },
          ),

          /// Notifications + Badge
          ListTile(
            leading: Icon(
              Icons.notifications_outlined,
              color: theme.iconTheme.color,
            ),
            title: Text(
              context.tr('drawer_notifications'),
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);

              // ✅ الأفضل: اعملي شاشة Notifications خاصة بالمريض
              // لو مش موجودة عندك حاليًا، ده مؤقت:
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
            Icons.history,
            context.tr('drawer_session_history'),
            () {
              Navigator.pop(context);
              // TODO: افتحي Session History screen لو عندك
            },
          ),

          _drawerItem(
            context,
            Icons.settings_outlined,
            context.tr('drawer_settings'),
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          const Spacer(),

          _drawerItem(
            context,
            Icons.logout_rounded,
            context.tr('drawer_logout'),
            () async {
              await LogoutFunction.logout(context);
            },
          ),
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
