import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_progress_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';

class PatientDrawer extends StatelessWidget {
  final String patientName;
  final String userId;
  final String? avatarUrl;

  const PatientDrawer({
    super.key,
    required this.patientName,
    required this.userId,
    this.avatarUrl,
  });

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
                AvatarWidget(
                  imageUrl: avatarUrl,
                  name: patientName,
                  radius: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        patientName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Patient',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _drawerItem(
            context,
            Icons.home_outlined,
            context.tr('drawer_home'),
            () => Navigator.pop(context),
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
                      PatientProgressScreen(patientName: patientName),
                ),
              );
            },
          ),

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
              // Patient notifications – placeholder for future patient-specific screen
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
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(role: 'patient'),
                ),
              );
            },
          ),

          const Spacer(),

          _drawerItem(
            context,
            Icons.logout_rounded,
            context.tr('drawer_logout'),
            () async => await LogoutFunction.logout(context),
          ),
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
