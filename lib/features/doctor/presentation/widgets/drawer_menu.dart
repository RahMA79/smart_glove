import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/supabase_client.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_notifications_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/my_patients_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/new_patient_request_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';

class DoctorDrawer extends StatefulWidget {
  const DoctorDrawer({super.key});

  @override
  State<DoctorDrawer> createState() => _DoctorDrawerState();
}

class _DoctorDrawerState extends State<DoctorDrawer> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final data = await supabase
        .from('users')
        .select('name, avatar_url')
        .eq('id', uid)
        .maybeSingle();
    if (!mounted) return;
    setState(() => _profile = data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _profile?['name']?.toString() ?? 'Doctor';
    final avatarUrl = _profile?['avatar_url']?.toString();

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: Row(
              children: [
                AvatarWidget(imageUrl: avatarUrl, name: name, radius: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
          _drawerItem(
            context,
            Icons.person_add,
            context.tr('New patient requests'),
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewPatientRequestScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.notifications,
            context.tr('Notifications'),
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorNotificationsScreen(),
                ),
              );
            },
          ),
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
          const SizedBox(height: 12),
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
