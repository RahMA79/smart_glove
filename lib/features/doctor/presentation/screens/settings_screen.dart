import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_glove/core/services/storage_service.dart';
import 'package:smart_glove/core/theme/theme_notifier.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/localization/locale_notifier.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/auth/presentation/widgets/logout_function.dart';
import 'package:smart_glove/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/supabase_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
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
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final url = await StorageService.uploadAvatar(
          userId: uid, file: File(picked.path));
      if (url != null) {
        await supabase
            .from('users')
            .update({'avatar_url': url}).eq('id', uid);
        // Also update role table
        final role = _profile?['role']?.toString();
        if (role == 'doctor') {
          await supabase
              .from('doctors')
              .update({'avatar_url': url}).eq('id', uid);
        } else {
          await supabase
              .from('patients')
              .update({'avatar_url': url}).eq('id', uid);
        }
        if (!mounted) return;
        setState(() => _profile = {...?_profile, 'avatar_url': url});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated!'),
            backgroundColor: Colors.green.shade600,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
              );
            }
          },
        ),
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
          Text(context.tr('Appearance'),
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.outline.withOpacity(0.15)),
            ),
            child: SwitchListTile(
              title: Text(context.tr('Dark Mode')),
              subtitle: Text(context.tr('Enable dark theme for the app')),
              value: themeNotifier.isDark,
              onChanged: (value) => themeNotifier.toggleTheme(value),
            ),
          ),

          const SizedBox(height: 20),

          // ── Account ──────────────────────────────────────────
          Text(context.tr('Account'),
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
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
                Divider(height: 1,
                    color: cs.outline.withOpacity(0.12), indent: 16),
                ListTile(
                  leading: Icon(Icons.logout, color: cs.error),
                  title: Text(context.tr('Logout'),
                      style: TextStyle(color: cs.error)),
                  onTap: () => LogoutFunction.logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
