import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_glove/features/patient/presentation/screens/session_history_screen.dart';
import 'package:smart_glove/features/patient/reqestscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_glove/core/services/storage_service.dart';
import 'package:smart_glove/core/theme/theme_notifier.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/localization/locale_notifier.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/new_patient_request_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_bottom_nav.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_nav_helper.dart';

import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:smart_glove/supabase_client.dart';

class SettingsScreen extends StatefulWidget {
  final String role;
  const SettingsScreen({super.key, this.role = 'doctor'});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _profile;
  bool _uploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

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
        .select('name, email, avatar_url, role')
        .eq('id', uid)
        .maybeSingle();
    if (!mounted) return;
    setState(() => _profile = data);
  }

  Future<void> _changeAvatar() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final url = await StorageService.uploadAvatar(
        userId: uid,
        file: File(picked.path),
      );
      if (url != null) {
        await supabase.from('users').update({'avatar_url': url}).eq('id', uid);
        // Also update role table
        final role = _profile?['role']?.toString();
        if (role == 'doctor') {
          await supabase
              .from('doctors')
              .update({'avatar_url': url})
              .eq('id', uid);
        } else {
          await supabase
              .from('patients')
              .update({'avatar_url': url})
              .eq('id', uid);
        }
        if (!mounted) return;
        setState(() => _profile = {...?_profile, 'avatar_url': url});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated!'),
            // success snackbar
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final langCode = localeNotifier.locale?.languageCode ?? 'en';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final name = _profile?['name']?.toString() ?? '';
    final email = _profile?['email']?.toString() ?? '';
    final avatarUrl = _profile?['avatar_url']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Settings')),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile section ──────────────────────────────────
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.outline.withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      AvatarWidget(
                        imageUrl: avatarUrl,
                        name: name,
                        radius: 36,
                        onTap: _changeAvatar,
                        showEditBadge: true,
                      ),
                      if (_uploadingAvatar)
                        const Positioned.fill(
                          child: CircleAvatar(
                            backgroundColor: Colors.black38,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'User' : name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Appearance ───────────────────────────────────────
          Text(
            context.tr('Appearance'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.outline.withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Theme'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ThemeModeBtn(
                            label: context.tr('Light'),
                            icon: Icons.wb_sunny_outlined,
                            selected:
                                themeNotifier.appThemeMode ==
                                AppThemeMode.light,
                            onTap: () => themeNotifier.setAppThemeMode(
                              AppThemeMode.light,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _ThemeModeBtn(
                            label: context.tr('System'),
                            icon: Icons.settings_outlined,
                            selected:
                                themeNotifier.appThemeMode ==
                                AppThemeMode.system,
                            onTap: () => themeNotifier.setAppThemeMode(
                              AppThemeMode.system,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _ThemeModeBtn(
                            label: context.tr('Dark'),
                            icon: Icons.nightlight_round_outlined,
                            selected:
                                themeNotifier.appThemeMode == AppThemeMode.dark,
                            onTap: () => themeNotifier.setAppThemeMode(
                              AppThemeMode.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Account ──────────────────────────────────────────
          Text(
            context.tr('Account'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.outline.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(context.tr('Language')),
                  subtitle: Text(
                    langCode == 'ar'
                        ? context.tr('Arabic')
                        : context.tr('English'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => SafeArea(
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
                      ),
                    );
                    if (selected != null) {
                      await localeNotifier.setLocale(Locale(selected));
                    }
                  },
                ),
                Divider(
                  height: 1,
                  color: cs.outline.withOpacity(0.12),
                  indent: 16,
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: cs.error),
                  title: Text(
                    context.tr('Logout'),
                    style: TextStyle(color: cs.error),
                  ),
                  onTap: () => LogoutFunction.logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Navigator.canPop(context)
          ? null // Pushed from drawer – use back button, no bottom nav
          : widget.role == 'doctor'
          ? DoctorBottomNav(
              currentIndex: 3,
              onChanged: (i) {
                if (i == 3) return;
                if (i == 0) doctorNavPush(context, const DoctorHomeScreen());
                if (i == 1) doctorNavPush(context, const CreateProgramScreen());
                if (i == 2)
                  doctorNavPush(context, const NewPatientRequestScreen());
              },
            )
          : PatientBottomNav(
              currentIndex: 3,
              onTap: (i) {
                if (i == 3) return;
                final uid = supabase.auth.currentUser?.id ?? '';
                void fadeTo(Widget page) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => page,
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                }

                if (i == 0) fadeTo(PatientHomeScreen(userId: uid));
                if (i == 1) fadeTo(const SessionHistoryScreen());
                if (i == 2) fadeTo(const DoctorRequestScreen());
              },
            ),
    );
  }
}

// ── Theme mode button ─────────────────────────────────────────────────────
class _ThemeModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? cs.primary : cs.onSurface.withOpacity(0.55),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? cs.onSurface : cs.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
